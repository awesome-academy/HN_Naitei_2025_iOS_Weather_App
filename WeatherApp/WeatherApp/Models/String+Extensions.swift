//
//  String+Extensions.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation

extension String {
    var locationFormat: String {
        return String(format: "%.4f", self)
    }
}

extension Double {
    var coordinateFormat: String {
        return String(format: "%.4f", self)
    }
}
