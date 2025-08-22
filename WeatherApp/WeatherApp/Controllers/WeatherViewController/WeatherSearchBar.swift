//
//  WeatherSearchBar.swift
//  WeatherApp
//
//  Created by Phan Quyen on 19/08/2025.
//

import UIKit

extension WeatherViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            searchWeather(for: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchWeather(for city: String) {
        showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hideLoading()
            
            let newWeatherData = WeatherDisplayData(
                cityName: city,
                temperature: "\(Int.random(in: 15...30))°",
                description: "",
                high: "",
                low: "",
                icon: "sun.max.fill"
            )
            
            self.weatherDataList.insert(newWeatherData, at: 0)
            self.weatherTableView.reloadData()
            self.citySearchBar.text = ""
            
            self.showDetailAlert(title: "Success", message: "Added \(city) to weather list")
        }
    }
}
