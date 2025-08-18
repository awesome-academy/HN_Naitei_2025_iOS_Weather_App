//
//  WeatherDisplayModels.swift
//  WeatherApp
//
//  Created by Phan Quyen on 18/08/2025.
//

import Foundation

struct WeatherDisplayData {
    let cityName: String
    let temperature: String
    let description: String
    let high: String
    let low: String
    let icon: String
}

struct HourlyDisplayData {
    let time: String
    let temperature: String
    let icon: String
}

struct WeeklyDisplayData {
    let day: String
    let high: String
    let low: String
    let icon: String
}
