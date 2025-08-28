//
//  HomeViewExtensions.swift
//  WeatherApp
//
//  Created by Phan Quyen on 18/08/2025.
//

import UIKit

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 ? hourlyData.count : weeklyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCollectionCell
        
        if hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 {
            cell.configureHourly(with: hourlyData[indexPath.item])
        } else {
            cell.configureWeekly(with: weeklyData[indexPath.item])
        }
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 {
            let hourlyItem = hourlyData[indexPath.item]
            showDetailAlert(title: "Hourly Forecast", message: "\(hourlyItem.time): \(hourlyItem.temperature)")
        } else {
            let weeklyItem = weeklyData[indexPath.item]
            showDetailAlert(title: "Daily Forecast", message: "\(weeklyItem.day): \(weeklyItem.high)/\(weeklyItem.low)")
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
