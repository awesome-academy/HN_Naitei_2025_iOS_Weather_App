//
//  WeatherViewController+Search.swift
//  WeatherApp
//
//  Created by Phan Quyen on 28/08/2025.
//

import UIKit

private struct AssociatedKeys {
    static var dropdownView = "dropdownView"
}

extension WeatherViewController: UISearchBarDelegate, SearchDropdownDelegate {
    
    func setupSearchBarWithHistory() {
        citySearchBar.delegate = self
        
        let dropdownView = SearchDropdownView()
        dropdownView.delegate = self
        dropdownView.isHidden = true
        dropdownView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(dropdownView)
        view.bringSubviewToFront(dropdownView)
        
        NSLayoutConstraint.activate([
            dropdownView.topAnchor.constraint(equalTo: citySearchBar.bottomAnchor, constant: 2),
            dropdownView.leadingAnchor.constraint(equalTo: citySearchBar.leadingAnchor),
            dropdownView.trailingAnchor.constraint(equalTo: citySearchBar.trailingAnchor),
            dropdownView.heightAnchor.constraint(lessThanOrEqualToConstant: 220)
        ])
        
        objc_setAssociatedObject(self, &AssociatedKeys.dropdownView, dropdownView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private var dropdownView: SearchDropdownView? {
        return objc_getAssociatedObject(self, &AssociatedKeys.dropdownView) as? SearchDropdownView
    }
    
    func didSelectSearchSuggestion(_ suggestion: String) {
        citySearchBar.text = suggestion
        citySearchBar.resignFirstResponder()
        searchCities(query: suggestion)
        dropdownView?.hide()
        SearchHistoryService.shared.saveSearch(suggestion)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text changed: \(searchText)")
        
        if searchText.isEmpty {
            dropdownView?.hide()
            showAllCitiesFromSearch()
        } else {
            let suggestions = SearchHistoryService.shared.getFilteredHistory(for: searchText)
            print("Suggestions: \(suggestions)")
            dropdownView?.updateSuggestions(suggestions)
            
            if searchText.count >= 2 {
                searchCities(query: searchText)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dropdownView?.hide()
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            SearchHistoryService.shared.saveSearch(searchText)
            searchCities(query: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        dropdownView?.hide()
        showAllCitiesFromSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Begin editing")
        if let text = searchBar.text, !text.isEmpty {
            let suggestions = SearchHistoryService.shared.getFilteredHistory(for: text)
            dropdownView?.updateSuggestions(suggestions)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dropdownView?.hide()
        }
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
                    self?.showAllCitiesFromSearch()
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
                icon: WeatherImages.morningSunny
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
    
    internal func showAllCitiesFromSearch() {
        loadSampleData()
    }
}
