//
//  WeatherViewController+TableView.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import UIKit

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell
        
        cell.delegate = self
        cell.configure(with: weatherDataList[indexPath.row])
        
        if indexPath.row == weatherDataList.count - 1 {
            loadMoreDataIfNeeded()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let availableHeight = screenHeight - 200
        return (availableHeight / 4.5) - 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedWeatherData = weatherDataList[indexPath.row]
        CityNavigationCoordinator.shared.navigateToHomeWith(
            weatherData: selectedWeatherData,
            from: self
        )
    }
}
