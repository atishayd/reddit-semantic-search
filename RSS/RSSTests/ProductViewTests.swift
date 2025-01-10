import XCTest
import SwiftUI
@testable import RSS

final class ProductViewTests: XCTestCase {
    func testProductViewLayout() {
        let sentiment = SentimentScore(positive: 0.6, neutral: 0.3, negative: 0.1)
        let product = Product(
            id: "test_id",
            name: "iPhone",
            imageURL: nil,
            sentiment: sentiment,
            recommendation: .buy,
            totalPostsAnalyzed: 100,
            topComments: ["Great product!"],
            subreddits: ["apple"]
        )
        
        let view = ProductView(product: product)
        
        // Test view hierarchy
        let viewHierarchy = try? view.inspect()
        XCTAssertNotNil(viewHierarchy)
        
        // Test recommendation section
        XCTAssertTrue(try view.inspect().find(text: "Reddit's Verdict").isPresent)
        XCTAssertTrue(try view.inspect().find(text: "Buy").isPresent)
    }
} 