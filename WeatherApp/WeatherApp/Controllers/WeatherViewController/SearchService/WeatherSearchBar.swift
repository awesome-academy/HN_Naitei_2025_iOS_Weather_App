//
//  WeatherSearchBar.swift
//  WeatherApp
//
//  Created by Phan Quyen on 19/08/2025.
//

import UIKit

extension WeatherViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            showAllCities()
        } else if searchText.count >= 2 {
            searchCities(query: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            searchCities(query: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        showAllCities()
    }
    
    private func searchCities(query: String) {
        showLoading()
        
        CitySearchService.shared.searchCities(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                switch result {
                case .success(let cities):
                    self?.displaySearchResults(cities)
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                    self?.showAllCities()
                }
            }
        }
    }
    
    private func displaySearchResults(_ cities: [CitySearchResult]) {
        weatherDataList = cities.map { city in
            WeatherDisplayData(
                cityName: city.displayName,
                temperature: "--°",
                description: "Loading...",
                high: "",
                low: "",
                icon: WeatherImages.morningSunny // Use consistent default
            )
        }
        
        weatherTableView.reloadData()
        
        if cities.isEmpty {
            showErrorAlert(message: "No cities")
        } else {
            loadWeatherForCities(cities)
        }
    }
    
    private func loadWeatherForCities(_ cities: [CitySearchResult]) {
        for (index, city) in cities.enumerated() {
            WeatherRepository.shared.getCurrentWeather(
                latitude: city.latitude,
                longitude: city.longitude
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let weatherData):
                        if index < self?.weatherDataList.count ?? 0 {
                            // Use consistent icon logic
                            let weatherIcon = WeatherImages.imageForWeatherData(weatherData)
                            
                            self?.weatherDataList[index] = WeatherDisplayData(
                                cityName: city.displayName,
                                temperature: weatherData.temperatureString,
                                description: weatherData.description,
                                high: "\(Int(weatherData.temperature + 5))°",
                                low: "\(Int(weatherData.temperature - 5))°",
                                icon: weatherIcon
                            )
                            
                            let indexPath = IndexPath(row: index, section: 0)
                            self?.weatherTableView.reloadRows(at: [indexPath], with: .none)
                        }
                    case .failure(let error):
                        print("Failed to load weather for \(city.name): \(error)")
                        if index < self?.weatherDataList.count ?? 0 {
                            self?.weatherDataList[index] = WeatherDisplayData(
                                cityName: city.displayName,
                                temperature: "N/A",
                                description: "Unable to load",
                                high: "--",
                                low: "--",
                                icon: WeatherImages.morningSunny
                            )
                            
                            let indexPath = IndexPath(row: index, section: 0)
                            self?.weatherTableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
            }
        }
    }
    
    private func showAllCities() {
        loadSampleData()
    }
}
