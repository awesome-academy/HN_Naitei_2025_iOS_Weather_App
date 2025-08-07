//
//  WeatherModels.swift
//  WeatherApp
//
//  Created by Phan Quyen on 07/08/2025.
//

import Foundation

struct WeatherResponse: Codable {
    let coord: Coordinates
    let weather: [Weather]
    let main: MainWeatherInfo
    let wind: Wind
    let dt: Int
    let sys: SystemInfo
    let name: String
    let cod: Int
}

struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeatherInfo: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct SystemInfo: Codable {
    let country: String
    let sunrise: Int
    let sunset: Int
}

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: CityInfo
}

struct ForecastItem: Codable {
    let dt: Int
    let main: MainWeatherInfo
    let weather: [Weather]
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather
        case dtTxt = "dt_txt"
    }
}

struct CityInfo: Codable {
    let name: String
    let country: String
}

struct WeatherData {
    let cityName: String
    let country: String
    let temperature: Double
    let description: String
    let icon: String
    let humidity: Int
    let windSpeed: Double
    let timestamp: Date
    
    init(from response: WeatherResponse) {
        cityName = response.name
        country = response.sys.country
        temperature = response.main.temp
        description = response.weather.first?.description.capitalized ?? ""
        icon = response.weather.first?.icon ?? ""
        humidity = response.main.humidity
        windSpeed = response.wind.speed
        timestamp = Date(timeIntervalSince1970: TimeInterval(response.dt))
    }
    
    var temperatureString: String {
        return String(format: "%.0f°C", temperature)
    }
    
    var humidityString: String {
        return "\(humidity)%"
    }
    
    var windString: String {
        return String(format: "%.1f m/s", windSpeed)
    }
}

struct HourlyForecast {
    let time: Date
    let temperature: Double
    let description: String
    let icon: String
    
    init(from item: ForecastItem) {
        time = Date(timeIntervalSince1970: TimeInterval(item.dt))
        temperature = item.main.temp
        description = item.weather.first?.description.capitalized ?? ""
        icon = item.weather.first?.icon ?? ""
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var temperatureString: String {
        return String(format: "%.0f°", temperature)
    }
}

struct DailyForecast {
    let date: Date
    let minTemperature: Double
    let maxTemperature: Double
    let description: String
    let icon: String
    
    init(from items: [ForecastItem]) {
        guard let firstItem = items.first else {
            date = Date()
            minTemperature = 0
            maxTemperature = 0
            description = ""
            icon = ""
            return
        }
        
        date = Date(timeIntervalSince1970: TimeInterval(firstItem.dt))
        let temperatures = items.map { $0.main.temp }
        minTemperature = temperatures.min() ?? 0
        maxTemperature = temperatures.max() ?? 0
        description = firstItem.weather.first?.description.capitalized ?? ""
        icon = firstItem.weather.first?.icon ?? ""
    }
    
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var temperatureRangeString: String {
        return String(format: "%.0f° / %.0f°", minTemperature, maxTemperature)
    }
}
