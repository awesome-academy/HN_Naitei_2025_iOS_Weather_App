//
//  ForecastDataSources.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import UIKit

protocol ForecastDataSourceDelegate: AnyObject {
    func didSelectHourlyForecast(_ forecast: HourlyDisplayData, at index: Int)
    func didSelectDailyForecast(_ forecast: WeeklyDisplayData, at index: Int)
}

class HourlyForecastDataSource: NSObject {
    weak var delegate: ForecastDataSourceDelegate?
    
    var hourlyForecasts: [HourlyForecast] = []
    var mockData: [HourlyDisplayData] = []
    
    private var displayData: [HourlyDisplayData] {
        if !hourlyForecasts.isEmpty {
            return hourlyForecasts.prefix(8).map { forecast in
                HourlyDisplayData(
                    time: forecast.timeString,
                    temperature: forecast.temperatureString,
                    icon: WeatherImages.imageForWeather(condition: forecast.description, iconCode: forecast.icon)
                )
            }
        }
        return mockData
    }
}

extension HourlyForecastDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCollectionCell
        cell.configureHourly(with: displayData[indexPath.item])
        return cell
    }
}

extension HourlyForecastDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectHourlyForecast(displayData[indexPath.item], at: indexPath.item)
    }
}

class DailyForecastDataSource: NSObject {
    weak var delegate: ForecastDataSourceDelegate?
    
    var dailyForecasts: [DailyForecast] = []
    var mockData: [WeeklyDisplayData] = []
    
    private var displayData: [WeeklyDisplayData] {
        if !dailyForecasts.isEmpty {
            return dailyForecasts.prefix(7).map { forecast in
                WeeklyDisplayData(
                    day: forecast.dayString,
                    high: String(format: "%.0f°", forecast.maxTemperature),
                    low: String(format: "%.0f°", forecast.minTemperature),
                    icon: WeatherImages.imageForWeather(condition: forecast.description, iconCode: forecast.icon)
                )
            }
        }
        return mockData
    }
}

extension DailyForecastDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCollectionCell
        cell.configureWeekly(with: displayData[indexPath.item])
        return cell
    }
}

extension DailyForecastDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectDailyForecast(displayData[indexPath.item], at: indexPath.item)
    }
}

extension DailyForecastDataSource: UICollectionViewDelegateFlowLayout {
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
