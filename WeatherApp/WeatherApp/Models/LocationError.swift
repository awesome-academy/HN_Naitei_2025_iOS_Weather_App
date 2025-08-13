//
//  LocationError.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation

enum LocationError: Error, LocalizedError {
    case permissionDenied
    case locationNotFound
    case networkError
    case invalidCoordinates
    case timeout
    case serviceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .locationNotFound:
            return "Location not found"
        case .networkError:
            return "Network error occurred"
        case .invalidCoordinates:
            return "Invalid coordinates"
        case .timeout:
            return "Location request timeout"
        case .serviceUnavailable:
            return "Location service unavailable"
        }
    }
}
