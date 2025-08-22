//
//  ForecastModels.swift
//  WeatherApp
//
//  Created by Phan Quyen on 07/08/2025.
//

import Foundation

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

struct HourlyForecast {
    let time: Date
    let temperature: Double
    let description: String
    let icon: String
    
    init(from item: ForecastItem) {
        self.time = Date(timeIntervalSince1970: TimeInterval(item.dt))
        self.temperature = item.main.temp
        self.description = item.weather.first?.description.capitalized ?? ""
        self.icon = item.weather.first?.icon ?? ""
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: time).lowercased()
    }
    
    var temperatureString: String {
        return String(format: "%.0f°", temperature)
    }
    
    var isCurrentHour: Bool {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        let forecastHour = calendar.component(.hour, from: time)
        return currentHour == forecastHour
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
            self.date = Date()
            self.minTemperature = 0
            self.maxTemperature = 0
            self.description = ""
            self.icon = ""
            return
        }
        
        self.date = Date(timeIntervalSince1970: TimeInterval(firstItem.dt))
        
        let temperatures = items.map { $0.main.temp }
        self.minTemperature = temperatures.min() ?? 0
        self.maxTemperature = temperatures.max() ?? 0
        
        self.description = firstItem.weather.first?.description.capitalized ?? ""
        self.icon = firstItem.weather.first?.icon ?? ""
    }
    
    var dayString: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
    }
    
    var temperatureRangeString: String {
        return String(format: "%.0f° / %.0f°", minTemperature, maxTemperature)
    }
}
