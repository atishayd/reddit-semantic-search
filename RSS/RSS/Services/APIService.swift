import Foundation
import SwiftUI

class APIService: ObservableObject {
    #if DEBUG
    private let baseURL = "http://192.168.86.44:8000"
    #else
    private let baseURL = "https://your-production-server.com"
    #endif
    
    func searchProduct(_ query: String) async throws -> Product {
        guard !query.isEmpty else {
            throw APIError.invalidURL
        }
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search?q=\(encodedQuery)") else {
            throw APIError.invalidURL
        }
        
        print("Attempting to connect to: \(url.absoluteString)")
        
        // Create URL request with timeout
        var request = URLRequest(url: url)
        request.timeoutInterval = 30  // Increase timeout to 30 seconds
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw APIError.unknown
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error with status code: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(Product.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to read data")")
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            print("Network error: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("URL Error code: \(urlError.code.rawValue)")
                print("URL Error description: \(urlError.localizedDescription)")
            }
            throw APIError.networkError(error)
        }
    }
} 

