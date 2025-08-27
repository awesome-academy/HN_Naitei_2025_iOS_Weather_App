//
//  HomeViewController+Navigation.swift
//  WeatherApp
//
//  Created by Phan Quyen on 27/08/2025.
//

import UIKit

extension HomeViewController {
    
    func updateDataForSelectedCity() {
        guard let selectedCity = selectedCityLocation else { return }
        loadWeatherForSelectedCity(selectedCity)
    }
    
    func updateDataForSelectedWeather() {
        guard let selectedWeather = selectedWeatherData else { return }
        
        DispatchQueue.main.async {
            self.currentWeatherData = selectedWeather
            self.cityNameLabel.text = selectedWeather.cityName
            self.mainTemperatureLabel.text = selectedWeather.temperature
            self.weatherDescriptionLabel.text = selectedWeather.description
            self.highLowTemperatureLabel.text = "H:\(selectedWeather.high) L:\(selectedWeather.low)"
            
            if let iconImage = UIImage(named: selectedWeather.icon) {
                self.weatherIconImageView.image = iconImage
            } else {
                let fallbackIcon = WeatherImages.morningSunny
                self.weatherIconImageView.image = UIImage(named: fallbackIcon)
            }
            
            self.collectionView.reloadData()
        }
        
        let components = selectedWeather.cityName.components(separatedBy: ",")
        let cityName = components.first?.trimmingCharacters(in: .whitespaces) ?? ""
        let country = components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : ""
        
        if !cityName.isEmpty {
            let cityLocation = CityLocation(
                name: cityName,
                country: country,
                state: nil,
                latitude: 0,
                longitude: 0
            )
            loadWeatherForSelectedCity(cityLocation)
        } else {
            hourlyDataSource.hourlyForecasts = []
            dailyDataSource.dailyForecasts = []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}
