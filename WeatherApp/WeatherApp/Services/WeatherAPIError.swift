//
//  WeatherAPIError.swift
//  WeatherApp
//
//  Created by Phan Quyen on 14/08/2025.
//

import Foundation

enum WeatherAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case networkError(NetworkError)
    case decodingError(Error)
    case invalidAPIKey
    case cityNotFound
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .networkError(let networkError):
            return "Network error: \(networkError.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Invalid API key"
        case .cityNotFound:
            return "City not found"
        case .rateLimitExceeded:
            return "API rate limit exceeded"
        }
    }
}
