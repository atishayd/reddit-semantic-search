import XCTest
@testable import RSS

final class ProductTests: XCTestCase {
    func testProductInitialization() {
        let sentiment = SentimentScore(positive: 0.6, neutral: 0.3, negative: 0.1)
        let product = Product(
            id: "test_id",
            name: "iPhone",
            imageURL: "https://example.com/image.jpg",
            sentiment: sentiment,
            recommendation: .buy,
            totalPostsAnalyzed: 100,
            topComments: ["Great product!"],
            subreddits: ["apple", "gadgets"]
        )
        
        XCTAssertEqual(product.id, "test_id")
        XCTAssertEqual(product.name, "iPhone")
        XCTAssertEqual(product.recommendation, .buy)
        XCTAssertEqual(product.totalPostsAnalyzed, 100)
    }
} 