//
//  String+Extensions.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation

extension String {
    static func formatCoordinates(latitude: Double, longitude: Double) -> String {
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
}
