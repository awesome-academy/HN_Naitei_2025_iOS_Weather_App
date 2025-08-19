//
//  WeatherImages.swift
//  WeatherApp
//
//  Created by Phan Quyen on 19/08/2025.
//

import Foundation

struct WeatherImages {
    
    static let nightRain = "night_rain"
    static let nightWind = "night_wind"
    static let morningHeavyRain = "morning_heavy_rain"
    static let tornado = "tornado"
    static let morningLightRain = "morning_light_rain"
    static let morningSunny = "morning_sunny"
    
    static let allImages = [
        nightRain, nightWind, morningHeavyRain, tornado, morningLightRain, morningSunny
    ]
    
    static func randomImage() -> String {
        return allImages.randomElement() ?? morningSunny
    }
}
