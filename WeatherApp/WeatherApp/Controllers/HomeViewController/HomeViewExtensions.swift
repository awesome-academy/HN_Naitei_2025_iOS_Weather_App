//
//  HomeViewExtensions.swift
//  WeatherApp
//
//  Created by Phan Quyen on 18/08/2025.
//

import UIKit

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 {
            return hourlyForecastData.isEmpty ? hourlyData.count : min(hourlyForecastData.count, 8)
        } else {
            return dailyForecastData.isEmpty ? weeklyData.count : min(dailyForecastData.count, 7)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCollectionCell
        
        if hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 {
            if !hourlyForecastData.isEmpty && indexPath.item < hourlyForecastData.count {
                let hourlyDataItem = hourlyForecastData[indexPath.item]
                let displayData = HourlyDisplayData(
                    time: hourlyDataItem.timeString,
                    temperature: hourlyDataItem.temperatureString,
                    icon: WeatherImages.imageForWeather(condition: hourlyDataItem.description, iconCode: hourlyDataItem.icon)
                )
                cell.configureHourly(with: displayData)
            } else {
                cell.configureHourly(with: hourlyData[indexPath.item])
            }
        } else {
            if !dailyForecastData.isEmpty && indexPath.item < dailyForecastData.count {
                let dailyDataItem = dailyForecastData[indexPath.item]
                let displayData = WeeklyDisplayData(
                    day: dailyDataItem.dayString,
                    high: String(format: "%.0f°", dailyDataItem.maxTemperature),
                    low: String(format: "%.0f°", dailyDataItem.minTemperature),
                    icon: WeatherImages.imageForWeather(condition: dailyDataItem.description, iconCode: dailyDataItem.icon)
                )
                cell.configureWeekly(with: displayData)
            } else {
                cell.configureWeekly(with: weeklyData[indexPath.item])
            }
        }
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 {
            if !hourlyForecastData.isEmpty && indexPath.item < hourlyForecastData.count {
                let hourlyItem = hourlyForecastData[indexPath.item]
                showDetailAlert(
                    title: "Hourly Forecast",
                    message: "\(hourlyItem.timeString): \(hourlyItem.temperatureString)\n\(hourlyItem.description.capitalized)"
                )
            } else {
                let hourlyItem = hourlyData[indexPath.item]
                showDetailAlert(title: "Hourly Forecast", message: "\(hourlyItem.time): \(hourlyItem.temperature)")
            }
        } else {
            if !dailyForecastData.isEmpty && indexPath.item < dailyForecastData.count {
                let dailyItem = dailyForecastData[indexPath.item]
                showDetailAlert(
                    title: "Daily Forecast",
                    message: "\(dailyItem.dayString)\nHigh: \(String(format: "%.0f°", dailyItem.maxTemperature))\nLow: \(String(format: "%.0f°", dailyItem.minTemperature))\n\(dailyItem.description.capitalized)"
                )
            } else {
                let weeklyItem = weeklyData[indexPath.item]
                showDetailAlert(title: "Daily Forecast", message: "\(weeklyItem.day): \(weeklyItem.high)/\(weeklyItem.low)")
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    }
}
