//
//  NetworkError.swift
//  WeatherApp
//
//  Created by Phan Quyen on 14/08/2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case serverError(Int)
    case noData
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .noData:
            return "No data received"
        case .decodingFailed:
            return "Failed to decode response"
        }
    }
}
