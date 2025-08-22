//
//  ForecastDataSourceDelegate.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import Foundation

protocol ForecastDataSourceDelegate: AnyObject {
    func didSelectHourlyForecast(_ forecast: HourlyDisplayData, at index: Int)
    func didSelectDailyForecast(_ forecast: WeeklyDisplayData, at index: Int)
}
