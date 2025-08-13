//
//  CitySearchResult.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation

struct CitySearchResult {
    let name: String
    let country: String
    let state: String?
    let latitude: Double
    let longitude: Double
    
    var displayName: String {
        let components = [name, state, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return components.joined(separator: ", ")
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
