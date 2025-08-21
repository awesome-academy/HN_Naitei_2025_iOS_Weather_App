//
//  CitySearchResponse.swift
//  WeatherApp
//
//  Created by Phan Quyen on 20/08/2025.
//

import Foundation

struct CitySearchResponse: Codable {
    let name: String
    let country: String
    let state: String?
    let lat: Double
    let lon: Double
}
