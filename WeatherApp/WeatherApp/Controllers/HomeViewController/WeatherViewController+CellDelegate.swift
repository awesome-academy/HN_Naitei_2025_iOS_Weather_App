//
//  WeatherViewController+CellDelegate.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import UIKit

extension WeatherViewController: WeatherTableViewCellDelegate {
    
    func didTapAddFavorite(_ weatherData: WeatherDisplayData) {
        addToFavorites(weatherData)
    }
    
    func didTapRemoveFavorite(_ weatherData: WeatherDisplayData) {
        removeFromFavorites(weatherData)
    }
    
    private func addToFavorites(_ weatherData: WeatherDisplayData) {
        showLoading()
        
        let cityName = weatherData.cityName.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? weatherData.cityName
        
        CitySearchService.shared.searchCities(query: cityName) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                switch result {
                case .success(let cities):
                    if let city = cities.first {
                        self?.saveCityToFavorites(city, weatherData: weatherData)
                    } else {
                        self?.showErrorAlert(message: "Unable to add \(cityName) to favorites")
                    }
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func saveCityToFavorites(_ city: CitySearchResult, weatherData: WeatherDisplayData) {
        let cityLocation = city.toCityLocation()
        
        DataManager.shared.saveFavorite(cityLocation: cityLocation) { [weak self] result in
            switch result {
            case .success:
                self?.showSuccessAlert(message: "Added \(city.name) to favorites")
                self?.updateFavoriteButtonStates()
            case .failure(let error):
                if case DataError.duplicateEntry = error {
                    self?.showErrorAlert(message: "\(city.name) is already in your favorites")
                } else {
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func removeFromFavorites(_ weatherData: WeatherDisplayData) {
        let cityName = weatherData.cityName.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? weatherData.cityName
        
        DataManager.shared.getAllFavorites { [weak self] result in
            switch result {
            case .success(let favorites):
                if let favorite = favorites.first(where: { $0.displayName.lowercased().contains(cityName.lowercased()) }) {
                    self?.deleteFavoriteCity(favorite)
                }
            case .failure(let error):
                self?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func deleteFavoriteCity(_ favorite: FavoriteCity) {
        let cityLocation = favorite.toCityLocation()
        
        DataManager.shared.removeFavorite(cityLocation: cityLocation) { [weak self] result in
            switch result {
            case .success:
                self?.showSuccessAlert(message: "Removed \(favorite.displayName) from favorites")
                self?.updateFavoriteButtonStates()
            case .failure(let error):
                self?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func updateFavoriteButtonStates() {
        for indexPath in weatherTableView.indexPathsForVisibleRows ?? [] {
            if let cell = weatherTableView.cellForRow(at: indexPath) as? WeatherTableViewCell {
                let weatherData = weatherDataList[indexPath.row]
                cell.configure(with: weatherData)
            }
        }
    }
}
