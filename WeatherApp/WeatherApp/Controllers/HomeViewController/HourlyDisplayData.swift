//
//  HourlyDisplayData.swift
//  WeatherApp
//
//  Created by Phan Quyen on 18/08/2025.
//

import Foundation

struct HourlyDisplayData {
    let time: String
    let temperature: String
    let icon: String
    
    init(time: String, temperature: String, icon: String) {
        self.time = time
        self.temperature = temperature
        self.icon = icon
    }
    
    init(from hourlyForecast: HourlyForecast) {
        self.time = hourlyForecast.isCurrentHour ? "Now" : hourlyForecast.hourString
        self.temperature = hourlyForecast.temperatureString
        self.icon = WeatherImages.imageForWeather(
            condition: hourlyForecast.description,
            iconCode: hourlyForecast.icon
        )
    }
    
    var weatherIcon: String {
        switch icon {
        case WeatherImages.morningSunny:
            return "☀"
        case WeatherImages.nightWind:
            return "☽"
        case WeatherImages.morningLightRain:
            return "🌧"
        case WeatherImages.morningHeavyRain:
            return "⛈"
        case WeatherImages.nightRain:
            return "🌧"
        case WeatherImages.tornado:
            return "⚡"
        default:
            return "☀"
        }
    }
}
