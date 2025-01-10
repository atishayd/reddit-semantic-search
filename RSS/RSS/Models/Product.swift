import Foundation
import SwiftUI

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let imageURL: String?
    let sentiment: SentimentScore
    let recommendation: Recommendation
    let totalPostsAnalyzed: Int
    let topComments: [String]
    let commentSentiments: [Double]
    let subreddits: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id, name, imageURL, sentiment, recommendation
        case totalPostsAnalyzed
        case topComments, commentSentiments, subreddits
    }
    
    enum Recommendation: String, Codable {
        case buy = "Buy"
        case wait = "Wait"
        case avoid = "Avoid"
        
        var color: UIColor {
            switch self {
            case .buy: return .systemGreen
            case .wait: return .systemYellow
            case .avoid: return .systemRed
            }
        }
    }
}

struct SentimentScore: Codable {
    let positive: Double
    let neutral: Double
    let negative: Double
}