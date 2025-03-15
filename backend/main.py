from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Literal
import asyncpraw
import os
from dotenv import load_dotenv
import math
import asyncio
from starlette.middleware.base import BaseHTTPMiddleware
import logging
import certifi
import ssl
import aiohttp
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

load_dotenv()
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    max_age=86400,
)

class SentimentScore(BaseModel):
    positive: float
    neutral: float
    negative: float

class Product(BaseModel):
    id: str
    name: str
    imageURL: Optional[str] = None
    sentiment: SentimentScore
    recommendation: Literal["Buy", "Wait", "Avoid"]
    totalPostsAnalyzed: int
    topComments: list[str] = []
    commentSentiments: list[float] = []
    subreddits: list[str] = []

class APIError(HTTPException):
    def __init__(self, error_type: str, detail: str):
        super().__init__(
            status_code=500,
            detail={"type": error_type, "message": detail}
        )

class TimeoutMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        try:
            # 90-second total request timeout
            return await asyncio.wait_for(call_next(request), timeout=90.0)
        except asyncio.TimeoutError:
            logger.error("Request timed out")
            raise APIError("networkError", "Request timed out")
        except Exception as e:
            logger.error(f"Error in middleware: {str(e)}")
            raise APIError("unknown", str(e))

app.add_middleware(TimeoutMiddleware)

analyzer = SentimentIntensityAnalyzer()

# ADD OR REMOVE AS NECESSARY FROM THE BANK ON WORD DOC
REVIEW_KEYWORDS = [
    "review", "impression", "feedback", "opinion", 
    "pros", "cons", "verdict", "recommend", "experience"
]

# FROM API
async def get_reddit():
    try:
        ssl_context = ssl.create_default_context(cafile=certifi.where())
        session = aiohttp.ClientSession(connector=aiohttp.TCPConnector(ssl=ssl_context))
        reddit = asyncpraw.Reddit(
            client_id=os.getenv("REDDIT_CLIENT_ID"),
            client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
            user_agent="RSS:v2.1 (by /u/your_username)",
            read_only=True,
            requestor_kwargs={"session": session}
        )
        await reddit.user.me()  # verify credentials
        return reddit, session

def is_review_comment(body: str) -> bool:

    # decide whether this comment body qualifies as 'review-like'.
    # we check for certain keywords + a minimum word count.
    text_lower = body.lower()
    has_keyword = any(k in text_lower for k in REVIEW_KEYWORDS)
    word_count = len(body.split())

    # STANDARD DO NOT CHANGE!
    if has_keyword or word_count > 30:
        return True
    return False

async def analyze_reddit_sentiment(query: str, max_posts: int = 10):
    """
    Conducts a weighted sentiment analysis on relevant 'review-like' 
    posts & comments from Reddit, returning:
      (sentiment_scores, recommendation, comments, subreddits, comment_sentiments).
    """
    if not query:
        raise APIError("invalidURL", "Search query cannot be empty")

    extended_query = f'("{query}" AND ({" OR ".join(REVIEW_KEYWORDS)}))'

    reddit, session = await get_reddit()
    if not reddit:
        raise APIError("invalidAPIKey", "Failed to initialize Reddit client")
    try:
        total_compound = 0.0
        total_weight = 0.0
        total_posts = 0
        subreddits = set()
        pos_comments = []
        neg_comments = []
        neu_comments = []
        
        logger.info(f"Searching for reviews: {extended_query}")
        subreddit = await reddit.subreddit("all")

        try:
            async with asyncio.timeout(60):
                async for submission in subreddit.search(extended_query, limit=max_posts, sort="relevance"):
                    subreddits.add(submission.subreddit.display_name)

                    # Weighted sentiment for submission title
                    submission_score = max(1, submission.score)
                    title_compound = analyzer.polarity_scores(submission.title)["compound"]
                    
                    total_compound += title_compound * submission_score
                    total_weight += submission_score
                    total_posts += 1

                    # Extract ONLY review-type comments
                    try:
                        async with asyncio.timeout(5):
                            submission_obj = await reddit.submission(id=submission.id)
                            submission_obj.comment_sort = "top"
                            await submission_obj.comments.replace_more(limit=0)
                            
                            # We'll look at top-level comments only
                            top_level_comments = submission_obj.comments.list()

                            review_count = 0
                            for comment in top_level_comments:
                                # JUST FOR DEMO, CHANGE WHEN PUSHED (<20) **********************************
                                if review_count >= 10:
                                    break
                                if not hasattr(comment, "body"):
                                    continue
                                
                                # WE JUST WANT REVIEW-LIKE COMMENTS
                                if not is_review_comment(comment.body):
                                    continue
                                
                                comment_score = max(1, comment.score)
                                c_compound = analyzer.polarity_scores(comment.body)["compound"]

                                # Weighted BY UPVOTES + LENGTH
                                length_factor = max(1.0, math.log2(len(comment.body.split()) + 1))
                                weight = comment_score * length_factor

                                total_compound += c_compound * weight
                                total_weight += weight
                                total_posts += 1

                                # ACTUAL CATEGORIZING
                                if c_compound >= 0.1:
                                    pos_comments.append((comment.body, c_compound))
                                elif c_compound <= -0.1:
                                    neg_comments.append((comment.body, c
