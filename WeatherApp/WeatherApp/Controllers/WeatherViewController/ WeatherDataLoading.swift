//
//   WeatherDataLoading.swift
//  WeatherApp
//
//  Created by Phan Quyen on 19/08/2025.
//

import UIKit

extension WeatherViewController {
    
    func loadSampleData() {
        let sampleCities = [
            ("Montreal", "Canada", 45.5017, -73.5673),
            ("Toronto", "Canada", 43.6532, -79.3832),
            ("Tokyo", "Japan", 35.6762, 139.6503),
            ("New York", "USA", 40.7128, -74.0060),
            ("London", "UK", 51.5074, -0.1278),
            ("Paris", "France", 48.8566, 2.3522)
        ]
        
        weatherDataList = sampleCities.prefix(itemsPerPage).map { city in
            WeatherDisplayData(
                cityName: "\(city.0), \(city.1)",
                temperature: "--°",
                description: "Loading...",
                high: "--",
                low: "--",
                icon: ""
            )
        }
        
        weatherTableView.reloadData()

        loadWeatherForSampleCities(Array(sampleCities.prefix(itemsPerPage)))
    }
    
    private func loadWeatherForSampleCities(_ cities: [(String, String, Double, Double)]) {
        for (index, city) in cities.enumerated() {
            WeatherRepository.shared.getCurrentWeather(
                latitude: city.2,
                longitude: city.3
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let weatherData):
                        if index < self?.weatherDataList.count ?? 0 {
                            self?.weatherDataList[index] = WeatherDisplayData(
                                cityName: "\(city.0), \(city.1)",
                                temperature: weatherData.temperatureString,
                                description: weatherData.description,
                                high: "\(Int(weatherData.temperature + 5))°",
                                low: "\(Int(weatherData.temperature - 5))°",
                                icon: WeatherImages.randomImage()
                            )
                            
                            let indexPath = IndexPath(row: index, section: 0)
                            self?.weatherTableView.reloadRows(at: [indexPath], with: .fade)
                        }
                    case .failure:
                        if index < self?.weatherDataList.count ?? 0 {
                            self?.weatherDataList[index] = WeatherDisplayData(
                                cityName: "\(city.0), \(city.1)",
                                temperature: "N/A",
                                description: "Unable to load",
                                high: "--",
                                low: "--",
                                icon: WeatherImages.morningSunny
                            )
                            
                            let indexPath = IndexPath(row: index, section: 0)
                            self?.weatherTableView.reloadRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
        }
    }
    
    func loadMoreDataIfNeeded() {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadNextBatch()
        }
    }
    
    func loadNextBatch() {
        let moreCities = [
            ("Amsterdam", "Netherlands", 52.3676, 4.9041),
            ("Vienna", "Austria", 48.2082, 16.3738),
            ("Prague", "Czech Republic", 50.0755, 14.4378)
        ]
        
        if currentPage < 4 {
            let startIndex = weatherDataList.count
            let newCities = moreCities.map { city in
                WeatherDisplayData(
                    cityName: "\(city.0), \(city.1)",
                    temperature: "--°",
                    description: "Loading...",
                    high: "--",
                    low: "--",
                    icon: ""
                )
            }
            
            weatherDataList.append(contentsOf: newCities)
            
            let indexPaths = (startIndex..<weatherDataList.count).map {
                IndexPath(row: $0, section: 0)
            }
            
            weatherTableView.insertRows(at: indexPaths, with: .fade)
            currentPage += 1
            
            // Load weather for new cities
            loadWeatherForSampleCities(moreCities)
        } else {
            hasMoreData = false
        }
        
        isLoadingMore = false
    }
}
