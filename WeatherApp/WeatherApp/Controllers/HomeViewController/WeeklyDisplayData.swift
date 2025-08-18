//
//  WeeklyDisplayData.swift
//  WeatherApp
//
//  Created by Phan Quyen on 18/08/2025.
//

import Foundation

struct WeeklyDisplayData {
    let day: String
    let high: String
    let low: String
    let icon: String
    
    var weatherIcon: String {
        switch icon {
        case "sun.max":
            return "○"
        case "cloud.sun":
            return "◐"
        case "cloud":
            return "●"
        case "cloud.rain":
            return "¤"
        case "moon":
            return "◑"
        case "snow":
            return "❋"
        default:
            return "○"
        }
    }
}
