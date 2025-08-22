//
//  FavoritesWeatherLoader.swift
//  WeatherApp
//
//  Created by Phan Quyen on 20/08/2025.
//

import UIKit

extension FavoritesViewController {
    
    func loadWeatherForFavorite(_ favorite: FavoriteCity, at indexPath: IndexPath) {
        let delay = Double(indexPath.row) * 0.4
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            WeatherRepository.shared.getCurrentWeather(
                latitude: favorite.latitude,
                longitude: favorite.longitude
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let weatherData):
                        let displayData = WeatherDisplayData(
                            cityName: favorite.displayName,
                            temperature: weatherData.temperatureString,
                            description: weatherData.description,
                            high: "",
                            low: "",
                            icon: self?.getWeatherIcon(from: weatherData) ?? WeatherImages.imageForWeatherData(weatherData)
                        )
                        
                        self?.updateCell(at: indexPath, with: favorite, weatherData: displayData)
                    case .failure(let error):
                        print("Failed to load \(favorite.displayName): \(error)")
                        let errorData = WeatherDisplayData(
                            cityName: favorite.displayName,
                            temperature: "N/A",
                            description: "Unable to load",
                            high: "",
                            low: "",
                            icon: WeatherImages.morningSunny
                        )
                        self?.updateCell(at: indexPath, with: favorite, weatherData: errorData)
                    }
                }
            }
        }
    }
    
    private func updateCell(at indexPath: IndexPath, with favorite: FavoriteCity, weatherData: WeatherDisplayData) {
        if let cell = favoritesTableView.cellForRow(at: indexPath) as? FavoritesTableViewCell {
            cell.configure(with: favorite, weatherData: weatherData)
        }
    }
    
    private func getWeatherIcon(from weatherData: WeatherData) -> String {
        let condition = weatherData.description.lowercased()
        let isDay = isCurrentlyDay()
        
        switch condition {
        case let c where c.contains("rain"):
            if c.contains("heavy") {
                return isDay ? WeatherImages.morningHeavyRain : WeatherImages.nightRain
            } else {
                return isDay ? WeatherImages.morningLightRain : WeatherImages.nightRain
            }
        case let c where c.contains("wind"):
            return isDay ? WeatherImages.tornado : WeatherImages.nightWind
        case let c where c.contains("clear") || c.contains("sun"):
            return isDay ? WeatherImages.morningSunny : WeatherImages.nightWind
        case let c where c.contains("cloud"):
            return isDay ? WeatherImages.morningSunny : WeatherImages.nightWind
        case let c where c.contains("storm"):
            return WeatherImages.tornado
        default:
            return isDay ? WeatherImages.morningSunny : WeatherImages.nightRain
        }
    }
    
    private func isCurrentlyDay() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour < 18
    }
    
    func deleteFavorite(_ favorite: FavoriteCity, at indexPath: IndexPath) {
        showConfirmationAlert(
            title: "Remove Favorite",
            message: "Are you sure you want to remove \(favorite.displayName) from your favorites?",
            confirmTitle: "Remove"
        ) { [weak self] in
            let cityLocation = favorite.toCityLocation()
            
            DataManager.shared.removeFavorite(cityLocation: cityLocation) { result in
                switch result {
                case .success:
                    self?.favoritesList.remove(at: indexPath.row)
                    self?.favoritesTableView.deleteRows(at: [indexPath], with: .fade)
                    self?.updateEmptyState()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self?.showSuccessAlert(message: "Removed \(favorite.displayName) from favorites")
                    }
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func refreshAllWeatherData() {
        for (index, favorite) in favoritesList.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            loadWeatherForFavorite(favorite, at: indexPath)
        }
    }
}