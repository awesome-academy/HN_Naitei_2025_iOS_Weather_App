//
//  HomeViewController+Extensions.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import UIKit
import CoreLocation

// MARK: - LocationManagerDelegate
extension HomeViewController: LocationManagerDelegate {
    
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        loadWeatherForLocation(location)
    }
    
    func locationManager(_ manager: LocationManager, didFailWithError error: LocationError) {
        hideLoading()
        
        let errorMessage: String
        switch error {
        case .permissionDenied:
            errorMessage = "Location access denied. Please enable location services in Settings to see weather for your current location."
        case .locationNotFound:
            errorMessage = "Unable to determine your location. Please try again."
        case .networkError:
            errorMessage = "Network error while getting location."
        case .serviceUnavailable:
            errorMessage = "Location services are not available."
        default:
            errorMessage = "Failed to get your location."
        }
        
        showErrorAlert(message: errorMessage) { [weak self] in
            self?.loadFallbackData()
        }
    }
    
    func locationManager(_ manager: LocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                manager.requestCurrentLocation()
            }
        case .denied, .restricted:
            loadFallbackData()
        default:
            break
        }
    }
}

// MARK: - ForecastDataSourceDelegate
extension HomeViewController: ForecastDataSourceDelegate {
    
    func didSelectHourlyForecast(_ forecast: HourlyDisplayData, at index: Int) {
        if !hourlyDataSource.hourlyForecasts.isEmpty && index < hourlyDataSource.hourlyForecasts.count {
            let hourlyItem = hourlyDataSource.hourlyForecasts[index]
            showDetailAlert(
                title: "Hourly Forecast",
                message: "\(hourlyItem.timeString): \(hourlyItem.temperatureString)\n\(hourlyItem.description.capitalized)"
            )
        } else {
            showDetailAlert(title: "Hourly Forecast", message: "\(forecast.time): \(forecast.temperature)")
        }
    }
    
    func didSelectDailyForecast(_ forecast: WeeklyDisplayData, at index: Int) {
        if !dailyDataSource.dailyForecasts.isEmpty && index < dailyDataSource.dailyForecasts.count {
            let dailyItem = dailyDataSource.dailyForecasts[index]
            showDetailAlert(
                title: "Daily Forecast",
                message: "\(dailyItem.dayString)\nHigh: \(String(format: "%.0f°", dailyItem.maxTemperature))\nLow: \(String(format: "%.0f°", dailyItem.minTemperature))\n\(dailyItem.description.capitalized)"
            )
        } else {
            showDetailAlert(title: "Daily Forecast", message: "\(forecast.day): \(forecast.high)/\(forecast.low)")
        }
    }
}
