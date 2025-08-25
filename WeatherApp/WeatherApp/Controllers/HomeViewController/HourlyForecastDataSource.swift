//
//  HourlyForecastDataSource.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import UIKit

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

// MARK: - UICollectionViewDataSource
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

// MARK: - UICollectionViewDelegate
extension HourlyForecastDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectHourlyForecast(displayData[indexPath.item], at: indexPath.item)
    }
}
