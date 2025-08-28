//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

class WeatherViewController: BaseViewController {
    
    @IBOutlet weak var citySearchBar: UISearchBar!
    @IBOutlet weak var weatherTableView: UITableView!
    
    var weatherDataList: [WeatherDisplayData] = []
    var currentPage = 1
    let itemsPerPage = 3
    var isLoadingMore = false
    var hasMoreData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupTableView()
        setupSearchBarWithHistory()
        loadInitialData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Weather view appeared")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            let dropdown = objc_getAssociatedObject(self, &AssociatedKeys.dropdownView) as? SearchDropdownView
            dropdown?.hide()
            self.weatherTableView.reloadData()
        }, completion: nil)
    }
    
    private func setupNavigationBar() {
        title = "Weather"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        addGradientBackground()
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        citySearchBar.placeholder = "Search for a city..."
        citySearchBar.delegate = self
        citySearchBar.backgroundImage = UIImage()
        citySearchBar.backgroundColor = .clear
        citySearchBar.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        citySearchBar.searchTextField.layer.cornerRadius = 12
        citySearchBar.searchTextField.textColor = .darkGray
        citySearchBar.searchTextField.font = UIFont.systemFont(ofSize: 16)
        citySearchBar.showsCancelButton = true
    }
    
    private func setupTableView() {
        weatherTableView.dataSource = self
        weatherTableView.delegate = self
        weatherTableView.backgroundColor = .clear
        weatherTableView.separatorStyle = .none
        weatherTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        weatherTableView.showsVerticalScrollIndicator = false
        weatherTableView.estimatedRowHeight = 120
        weatherTableView.rowHeight = UITableView.automaticDimension
    }
    
    func loadInitialData() {
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
                icon: WeatherImages.morningSunny
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
                            let weatherIcon = WeatherImages.imageForWeatherData(weatherData)
                            
                            self?.weatherDataList[index] = WeatherDisplayData(
                                cityName: "\(city.0), \(city.1)",
                                temperature: weatherData.temperatureString,
                                description: weatherData.description,
                                high: "\(Int(weatherData.temperature + 5))°",
                                low: "\(Int(weatherData.temperature - 5))°",
                                icon: weatherIcon
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
}

// MARK: - UITableViewDataSource, UITableViewDelegate
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
        let screenWidth = UIScreen.main.bounds.width
        let isLandscape = screenWidth > screenHeight
        
        if isLandscape {
            return min(80, screenHeight / 6)
        } else {
            let availableHeight = screenHeight - 200
            return max(100, (availableHeight / 4.5) - 35)
        }
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

// MARK: - WeatherTableViewCellDelegate
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

private struct AssociatedKeys {
    static var dropdownView = "dropdownView"
}