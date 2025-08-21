//
//  WeatherImages+Logic.swift
//  WeatherApp
//
//  Created by Phan Quyen on 21/08/2025.
//

import Foundation

extension WeatherImages {
    
    static func imageForWeather(condition: String, iconCode: String? = nil) -> String {
        let condition = condition.lowercased()
        let isDay = isCurrentlyDay()

        if let iconCode = iconCode {
            return imageFromIconCode(iconCode)
        }

        return imageFromCondition(condition, isDay: isDay)
    }
    
    private static func imageFromIconCode(_ iconCode: String) -> String {
        let isDay = iconCode.hasSuffix("d")
        let weatherCode = String(iconCode.dropLast())
        
        switch weatherCode {
        case "01": // clear sky
            return isDay ? morningSunny : nightWind
        case "02", "03", "04":
            return isDay ? morningSunny : nightWind
        case "09":
            return isDay ? morningLightRain : nightRain
        case "10":
            return isDay ? morningLightRain : nightRain
        case "11":
            return tornado
        case "13":
            return isDay ? morningHeavyRain : nightRain
        case "50":
            return isDay ? morningSunny : nightWind
        default:
            return isDay ? morningSunny : nightRain
        }
    }
    
    private static func imageFromCondition(_ condition: String, isDay: Bool) -> String {
        switch condition {
        case let c where c.contains("clear") || c.contains("sunny"):
            return isDay ? morningSunny : nightWind
            
        case let c where c.contains("cloud"):
            if c.contains("few") || c.contains("scattered") {
                return isDay ? morningSunny : nightWind
            } else {
                return isDay ? morningSunny : nightWind
            }
            
        case let c where c.contains("rain"):
            if c.contains("heavy") || c.contains("moderate") {
                return isDay ? morningHeavyRain : nightRain
            } else {
                return isDay ? morningLightRain : nightRain
            }
            
        case let c where c.contains("drizzle") || c.contains("shower"):
            return isDay ? morningLightRain : nightRain
            
        case let c where c.contains("storm") || c.contains("thunder"):
            return tornado
            
        case let c where c.contains("snow") || c.contains("sleet"):
            return isDay ? morningHeavyRain : nightRain
            
        case let c where c.contains("mist") || c.contains("fog") || c.contains("haze"):
            return isDay ? morningSunny : nightWind
            
        case let c where c.contains("wind"):
            return isDay ? nightWind : nightWind
            
        default:
            return isDay ? morningSunny : nightRain
        }
    }
    
    private static func isCurrentlyDay() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour < 18
    }
    
    // Helper method to get weather condition from weather data
    static func imageForWeatherData(_ weatherData: WeatherData) -> String {
        return imageForWeather(
            condition: weatherData.description,
            iconCode: extractIconCodeFromWeatherData(weatherData)
        )
    }
    
    private static func extractIconCodeFromWeatherData(_ weatherData: WeatherData) -> String? {

        return weatherData.icon
    }
}
