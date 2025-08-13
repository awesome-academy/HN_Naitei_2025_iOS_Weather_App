//
//  CityLocation.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
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
        let components = [name, state, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }
    
    var coordinatesString: String {
        return String.formatCoordinates(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    func distance(from location: CLLocation) -> CLLocationDistance {
        let cityLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        return location.distance(from: cityLocation)
    }
}
