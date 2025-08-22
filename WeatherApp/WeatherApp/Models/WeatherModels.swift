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
    let sys: SystemInfo?
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
    let deg: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        speed = try container.decode(Double.self, forKey: .speed)
        deg = try container.decodeIfPresent(Int.self, forKey: .deg) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case speed, deg
    }
}

struct SystemInfo: Codable {
    let country: String?
    let sunrise: Int?
    let sunset: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? "Unknown"
        sunrise = try container.decodeIfPresent(Int.self, forKey: .sunrise)
        sunset = try container.decodeIfPresent(Int.self, forKey: .sunset)
    }
    
    enum CodingKeys: String, CodingKey {
        case country, sunrise, sunset
    }
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
        self.cityName = response.name
        self.country = response.sys?.country ?? "Unknown"
        self.temperature = response.main.temp
        self.description = response.weather.first?.description.capitalized ?? ""
        self.icon = response.weather.first?.icon ?? ""
        self.humidity = response.main.humidity
        self.windSpeed = response.wind.speed
        self.timestamp = Date(timeIntervalSince1970: TimeInterval(response.dt))
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
