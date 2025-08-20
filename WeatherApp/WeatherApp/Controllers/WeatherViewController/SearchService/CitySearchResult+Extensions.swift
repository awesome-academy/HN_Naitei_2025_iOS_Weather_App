//
//  CitySearchResult+Extensions.swift
//  WeatherApp
//
//  Created by Phan Quyen on 20/08/2025.
//

import Foundation

extension CitySearchResult {
    init(from response: CitySearchResponse) {
        self.name = response.name
        self.country = response.country
        self.state = response.state
        self.latitude = response.lat
        self.longitude = response.lon
    }
}
