import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from main import app, analyze_reddit_sentiment, fetch_product_image

client = TestClient(app)

@pytest.fixture
def mock_reddit():
    with patch('main.reddit') as mock:
        # Create mock submission and comments
        mock_submission = MagicMock()
        mock_submission.title = "Great product!"
        mock_submission.subreddit.display_name = "gadgets"
        
        mock_comment = MagicMock()
        mock_comment.body = "This is amazing!"
        mock_submission.comments = [mock_comment]
        
        # Setup mock search results
        mock.subreddit().search.return_value = [mock_submission]
        yield mock

@pytest.fixture
def mock_redis():
    with patch('main.redis_client') as mock:
        yield mock

def test_search_endpoint():
    response = client.get("/search?q=iphone")
    assert response.status_code == 200
    data = response.json()
    assert "id" in data
    assert "sentiment" in data
    assert "recommendation" in data

def test_analyze_reddit_sentiment(mock_reddit):
    sentiment, recommendation, comments, subreddits = analyze_reddit_sentiment("test product")
    assert isinstance(sentiment.positive, float)
    assert recommendation in ["Buy", "Wait", "Avoid"]
    assert isinstance(comments, list)
    assert isinstance(subreddits, list)

@pytest.mark.asyncio
async def test_fetch_product_image(mock_redis):
    # Test cache hit
    mock_redis.get.return_value = "cached_image_url"
    image_url = await fetch_product_image("test product")
    assert image_url == "cached_image_url"

    # Test cache miss and API call
    mock_redis.get.return_value = None
    with patch('aiohttp.ClientSession.get') as mock_get:
        mock_response = MagicMock()
        mock_response.status = 200
        mock_response.json.return_value = {
            "items": [{"link": "test_image_url"}]
        }
        mock_get.return_value.__aenter__.return_value = mock_response
        
        image_url = await fetch_product_image("test product")
        assert image_url == "test_image_url" 