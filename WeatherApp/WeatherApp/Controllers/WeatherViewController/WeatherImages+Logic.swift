//
//  WeatherImages+Logic.swift
//  WeatherApp
//
//  Created by Phan Quyen on 21/08/2025.
//

import Foundation

extension WeatherImages {
    
    static func imageForWeather(condition: String, iconCode: String? = nil) -> String {
        if let iconCode = iconCode, !iconCode.isEmpty {
            return imageFromIconCode(iconCode)
        }
        return imageFromCondition(condition)
    }
    
    private static func imageFromIconCode(_ iconCode: String) -> String {
        let isDay = iconCode.hasSuffix("d")
        let weatherCode = String(iconCode.dropLast())
        
        switch weatherCode {
        case "01":
            return isDay ? morningSunny : nightWind
        case "02":
            return isDay ? morningSunny : nightWind
        case "03", "04":
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
            return morningSunny
        }
    }
    
    private static func imageFromCondition(_ condition: String) -> String {
        let isDay = isCurrentlyDay()
        
        switch condition.lowercased() {
        case let c where c.contains("clear") || c.contains("sunny"):
            return isDay ? morningSunny : nightWind
        case let c where c.contains("cloud"):
            return isDay ? morningSunny : nightWind
        case let c where c.contains("rain"):
            if c.contains("heavy") {
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
        default:
            return isDay ? morningSunny : nightRain
        }
    }
    
    private static func isCurrentlyDay() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour < 18
    }
    
    static func imageForWeatherData(_ weatherData: WeatherData) -> String {
        return imageForWeather(
            condition: weatherData.description,
            iconCode: weatherData.icon
        )
    }
    
    static func getConsistentIcon(for weatherData: WeatherDisplayData, fromOriginalIcon originalIcon: String? = nil) -> String {
        return weatherData.icon
    }
}
