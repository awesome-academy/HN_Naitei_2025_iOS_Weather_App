//
//  WeatherNotificationService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import Foundation
import CoreLocation

class WeatherNotificationService {
    static let shared = WeatherNotificationService()
    
    private init() {}
    
    func sendCurrentWeatherNotification() {
        getCurrentLocationWeather { location, temperature, condition in
            NotificationManager.shared.scheduleWeatherNotificationWithData(
                location: location,
                temperature: temperature,
                condition: condition
            )
        }
    }
    
    private func getCurrentLocationWeather(completion: @escaping (String, String, String) -> Void) {
        let locationManager = LocationManager.shared
        
        guard let currentLocation = locationManager.getCurrentLocation() else {
            completion("Current Location", "N/A", "Unable to get location")
            return
        }
        
        WeatherRepository.shared.getCurrentWeather(
            latitude: currentLocation.coordinate.latitude,
            longitude: currentLocation.coordinate.longitude
        ) { result in
            switch result {
            case .success(let weatherData):
                let location = weatherData.cityName.isEmpty ? "Current Location" : weatherData.cityName
                let temperature = weatherData.temperatureString
                let condition = self.formatWeatherCondition(weatherData.description)
                
                completion(location, temperature, condition)
                
            case .failure:
                completion("Current Location", "N/A", "Unable to get weather")
            }
        }
    }
    
    private func formatWeatherCondition(_ description: String) -> String {
        let lowercased = description.lowercased()
        
        if lowercased.contains("clear") || lowercased.contains("sunny") {
            return "Sunny"
        } else if lowercased.contains("cloud") {
            return "Cloudy"
        } else if lowercased.contains("rain") {
            return "Rainy"
        } else if lowercased.contains("snow") {
            return "Snowy"
        } else if lowercased.contains("storm") || lowercased.contains("thunder") {
            return "Stormy"
        } else if lowercased.contains("mist") || lowercased.contains("fog") {
            return "Foggy"
        } else {
            return description.capitalized
        }
    }
}
