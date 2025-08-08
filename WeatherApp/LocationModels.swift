//
//  LocationModels.swift
//  WeatherApp
//
//  Created by Phan Quyen on 07/08/2025.
//

import Foundation
import CoreLocation

struct CityLocation {
    let name: String
    let country: String
    let state: String?
    let coordinates: CLLocationCoordinate2D
    
    init(name: String, country: String, state: String? = nil, latitude: Double, longitude: Double) {
        self.name = name
        self.country = country
        self.state = state
        self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var displayName: String {
        if let state = state, !state.isEmpty {
            return "\(name), \(state), \(country)"
        } else {
            return "\(name), \(country)"
        }
    }
    
    var coordinatesString: String {
        return String(format: "%.4f, %.4f", coordinates.latitude, coordinates.longitude)
    }
    
    func distance(from location: CLLocation) -> CLLocationDistance {
        let cityLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        return location.distance(from: cityLocation)
    }
}

struct CitySearchResult {
    let name: String
    let country: String
    let state: String?
    let latitude: Double
    let longitude: Double
    
    var displayName: String {
        if let state = state, !state.isEmpty {
            return "\(name), \(state), \(country)"
        } else {
            return "\(name), \(country)"
        }
    }
    
    func toCityLocation() -> CityLocation {
        return CityLocation(
            name: name,
            country: country,
            state: state,
            latitude: latitude,
            longitude: longitude
        )
    }
}

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

enum LocationValidator {
    static func isValidLatitude(_ latitude: Double) -> Bool {
        return latitude >= -90.0 && latitude <= 90.0
    }
    
    static func isValidLongitude(_ longitude: Double) -> Bool {
        return longitude >= -180.0 && longitude <= 180.0
    }
    
    static func isValidCoordinate(latitude: Double, longitude: Double) -> Bool {
        return isValidLatitude(latitude) && isValidLongitude(longitude)
    }
    
    static func validateCityLocation(_ location: CityLocation) throws {
        guard !location.name.isEmpty else {
            throw LocationError.invalidCoordinates
        }
        
        guard !location.country.isEmpty else {
            throw LocationError.invalidCoordinates
        }
        
        guard isValidCoordinate(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude) else {
            throw LocationError.invalidCoordinates
        }
    }
    
    static func validateCityName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
