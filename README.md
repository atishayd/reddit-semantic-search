# Reddit Sentiment Search

An iOS app that performs real-time sentiment analysis on Reddit discussions about products, helping users make informed purchasing decisions.

## Features
- Real-time Reddit sentiment analysis
- Visual sentiment breakdown with charts
- Product recommendations (Buy/Wait/Avoid)
- Notable community comments with sentiment indicators
- Modern, native iOS design with smooth animations
- Subreddit source tracking

## 🛠️ Tech Stack
- **Frontend**: SwiftUI, Charts
- **Backend**: FastAPI, VADER Sentiment
- **API**: Reddit API (asyncpraw)

## Getting Started

### Prerequisites
- iOS 17.0+
- Xcode 15.0+
- Python 3.11+
- Reddit API credentials

### Backend Setup
1. Navigate to backend directory:
```bash
cd backend
python -m venv venv
source venv/bin/activate
```
2. Install Dependencies
```python
pip install -r requirements.txt
```
3. Set up environment variables (edit .env with your environment variables):
```python
cp .env.example .env
```
4. Start the server:
```python
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### iOS App Setup
1. Open `RSS.xcodeproj` in Xcode
2. Update `APIService.swift` with your local IP:

```swift
#if DEBUG
private let baseURL = "http://YOUR_IP_HERE:8000"
#else
private let baseURL = "https://your-production-server.com"
#endif
```

3. Build and run

## Getting Reddit API Credentials
1. Visit https://www.reddit.com/prefs/apps
2. Click "create another app..."
3. Fill in:
   - Name: RSS
   - Type: Script
   - Description: Reddit Sentiment Search
   - Redirect URI: http://localhost:8000
4. Save your:
   - Client ID (under app name)
   - Client Secret

## Security Note
The `.env` file containing your Reddit API credentials is excluded from git tracking. Never commit this file. Use `.env.example` as a template to create your own `.env` file locally.

## 🔍 Troubleshooting

### Common Issues
1. "Cannot connect to backend":
   - Verify Python server is running
   - Check IP address in APIService.swift
   - Ensure devices are on same network

2. "Reddit API errors":
   - Verify credentials in .env
   - Check API rate limits
   - Ensure Reddit app configuration

### Finding Your IP Address
```bash
ipconfig getifaddr en0
```

## Acknowledgments
- [VADER Sentiment Analysis](https://github.com/cjhutto/vaderSentiment)
- [Reddit API](https://www.reddit.com/dev/api/)
- [FastAPI](https://fastapi.tiangolo.com/)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
