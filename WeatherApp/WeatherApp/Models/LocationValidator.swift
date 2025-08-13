//
//  LocationValidator.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation

class LocationValidator {
    
    func isValidLatitude(_ latitude: Double) -> Bool {
        return latitude >= -90.0 && latitude <= 90.0
    }
    
    func isValidLongitude(_ longitude: Double) -> Bool {
        return longitude >= -180.0 && longitude <= 180.0
    }
    
    func isValidCoordinate(latitude: Double, longitude: Double) -> Bool {
        return isValidLatitude(latitude) && isValidLongitude(longitude)
    }
    
    func validateCityLocation(_ location: CityLocation) throws {
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
    
    func validateCityName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
