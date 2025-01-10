import Foundation
import SwiftUI

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case quotaExceeded
    case invalidAPIKey
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to process data: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .quotaExceeded:
            return "API quota exceeded. Please try again later."
        case .invalidAPIKey:
            return "Invalid API key. Please contact support."
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 
