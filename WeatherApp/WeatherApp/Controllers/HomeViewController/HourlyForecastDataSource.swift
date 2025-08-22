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
                HourlyDisplayData(from: forecast)
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

extension HourlyForecastDataSource: UICollectionViewDelegateFlowLayout {
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
