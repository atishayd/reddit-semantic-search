import XCTest
@testable import RSS

final class APIServiceTests: XCTestCase {
    var apiService: APIService!
    
    override func setUp() {
        super.setUp()
        apiService = APIService()
    }
    
    func testSearchProduct() async throws {
        // Test successful search
        do {
            let product = try await apiService.searchProduct("iPhone")
            XCTAssertNotNil(product)
            XCTAssertEqual(product.name, "iPhone")
        } catch {
            XCTFail("Search should succeed: \(error)")
        }
        
        // Test invalid query
        do {
            _ = try await apiService.searchProduct("")
            XCTFail("Empty query should throw error")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }
} 