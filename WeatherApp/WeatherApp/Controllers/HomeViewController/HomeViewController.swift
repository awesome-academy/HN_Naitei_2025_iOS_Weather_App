//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit
import CoreLocation

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var mainTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var highLowTemperatureLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var hourlyWeeklySegmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var currentWeatherData: WeatherDisplayData?
    
    var selectedCityLocation: CityLocation?
    var selectedWeatherData: WeatherDisplayData?
    
    private let locationManager = LocationManager.shared
    private let hourlyDataSource = HourlyForecastDataSource()
    private let dailyDataSource = DailyForecastDataSource()
    
    private let mockHourlyData = [
        HourlyDisplayData(time: "Now", temperature: "38°", icon: "sun.max"),
        HourlyDisplayData(time: "18h", temperature: "36°", icon: "cloud.sun"),
        HourlyDisplayData(time: "20h", temperature: "34°", icon: "cloud"),
        HourlyDisplayData(time: "22h", temperature: "32°", icon: "moon")
    ]
    
    private let mockWeeklyData = [
        WeeklyDisplayData(day: "Today", high: "38°", low: "25°", icon: "sun.max"),
        WeeklyDisplayData(day: "Tomorrow", high: "36°", low: "23°", icon: "cloud.sun"),
        WeeklyDisplayData(day: "Wed", high: "34°", low: "22°", icon: "cloud.rain"),
        WeeklyDisplayData(day: "Thu", high: "32°", low: "20°", icon: "cloud.rain")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupCollectionView()
        setupPullToRefresh()
        setupForecastBackground()
        setupDataSources()
        setupLocationManager()
        
        if let selectedCity = selectedCityLocation {
            loadWeatherForSelectedCity(selectedCity)
        } else if let selectedWeather = selectedWeatherData {
            updateUI(with: selectedWeather)
            if let city = getCityLocationFromWeatherData(selectedWeather) {
                loadForecastForSelectedCity(city)
            }
        } else {
            loadInitialData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if selectedCityLocation == nil && selectedWeatherData == nil {
            requestLocationAndLoadWeather()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideLoading()
    }
    
    deinit {
        locationManager.delegate = nil
        collectionView?.delegate = nil
        collectionView?.dataSource = nil
    }
    
    private func setupNavigationBar() {
        title = ""
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupUI() {
        setupSegmentedControl()
        setupLabels()
        setupImageViews()
    }
    
    private func setupSegmentedControl() {
        hourlyWeeklySegmentedControl.selectedSegmentIndex = 0
    }
    
    private func setupLabels() {
        cityNameLabel.text = ""
        mainTemperatureLabel.text = "--°"
        weatherDescriptionLabel.text = "Getting your location..."
        highLowTemperatureLabel.text = "H:--° L:--°"
    }
    
    private func setupImageViews() {
        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.image = UIImage(named: WeatherImages.morningSunny)
    }
    
    private func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        
        collectionView.showsHorizontalScrollIndicator = false
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumInteritemSpacing = 35
            flowLayout.minimumLineSpacing = 35
            flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        }
    }
    
    private func setupDataSources() {
        hourlyDataSource.mockData = mockHourlyData
        dailyDataSource.mockData = mockWeeklyData
        
        hourlyDataSource.delegate = self
        dailyDataSource.delegate = self
        
        updateCollectionViewDataSource()
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
    }
    
    private func loadInitialData() {
        showLoading()
        requestLocationAndLoadWeather()
    }
    
    private func requestLocationAndLoadWeather() {
        guard !isLoading else { return }
        
        weatherDescriptionLabel.text = "Getting your location..."
        
        if locationManager.hasLocationPermission {
            locationManager.requestCurrentLocation()
        } else {
            locationManager.requestLocationPermission()
        }
    }
    
    private func loadWeatherForLocation(_ location: CLLocation) {
        showLoading()
        weatherDescriptionLabel.text = "Loading weather..."
        
        WeatherRepository.shared.getCurrentWeather(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self?.handleWeatherSuccess(weatherData)
                    self?.loadForecastData(location)
                case .failure(let error):
                    self?.handleWeatherError(error)
                }
            }
        }
    }
    
    private func loadForecastData(_ location: CLLocation) {
        WeatherRepository.shared.getForecast(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (hourlyForecasts, dailyForecasts)):
                    self?.updateForecastData(hourly: hourlyForecasts, daily: dailyForecasts)
                case .failure(let error):
                    print("Failed to load forecast: \(error)")
                }
                self?.hideLoading()
            }
        }
    }
    
    func loadWeatherForSelectedCity(_ cityLocation: CityLocation) {
        showLoading()
        weatherDescriptionLabel.text = "Loading weather..."
        
        WeatherRepository.shared.getCurrentWeather(
            latitude: cityLocation.coordinates.latitude,
            longitude: cityLocation.coordinates.longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self?.handleWeatherSuccess(weatherData)
                    self?.loadForecastForSelectedCity(cityLocation)
                case .failure(let error):
                    self?.handleWeatherError(error)
                }
            }
        }
    }
    
    private func loadForecastForSelectedCity(_ cityLocation: CityLocation) {
        WeatherRepository.shared.getForecast(
            latitude: cityLocation.coordinates.latitude,
            longitude: cityLocation.coordinates.longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (hourlyForecasts, dailyForecasts)):
                    self?.updateForecastData(hourly: hourlyForecasts, daily: dailyForecasts)
                case .failure(let error):
                    print("Failed to load forecast: \(error)")
                }
                self?.hideLoading()
            }
        }
    }
    
    private func updateForecastData(hourly: [HourlyForecast], daily: [DailyForecast]) {
        hourlyDataSource.hourlyForecasts = hourly
        dailyDataSource.dailyForecasts = daily
        collectionView.reloadData()
    }
    
    private func getCityLocationFromWeatherData(_ weatherData: WeatherDisplayData) -> CityLocation? {
        let components = weatherData.cityName.components(separatedBy: ",")
        let cityName = components.first?.trimmingCharacters(in: .whitespaces) ?? ""
        let country = components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : ""
        
        return CityLocation(
            name: cityName,
            country: country,
            state: nil,
            latitude: 0,
            longitude: 0
        )
    }
    
    private func handleWeatherSuccess(_ weatherData: WeatherData) {
        let displayData = WeatherDisplayData(
            cityName: "\(weatherData.cityName), \(weatherData.country)",
            temperature: weatherData.temperatureString,
            description: weatherData.description,
            high: String(format: "%.0f°", weatherData.temperature + 5),
            low: String(format: "%.0f°", weatherData.temperature - 5),
            icon: WeatherImages.imageForWeatherData(weatherData)
        )
        
        updateUI(with: displayData)
    }
    
    private func handleWeatherError(_ error: WeatherAPIError) {
        hideLoading()
        weatherDescriptionLabel.text = "Unable to load weather"
        
        let errorMessage: String
        switch error {
        case .networkError:
            errorMessage = "Network connection failed. Please check your internet connection."
        case .cityNotFound:
            errorMessage = "Weather data not available for this location."
        case .invalidAPIKey:
            errorMessage = "Weather service unavailable."
        default:
            errorMessage = "Failed to load weather data."
        }
        
        showErrorAlert(message: errorMessage) { [weak self] in
            self?.loadFallbackData()
        }
    }
    
    private func loadFallbackData() {
        let fallbackData = WeatherDisplayData(
            cityName: "Current Location",
            temperature: "--°",
            description: "Weather unavailable",
            high: "--°",
            low: "--°",
            icon: WeatherImages.morningSunny
        )
        updateUI(with: fallbackData)
    }
    
    private func loadMockWeatherData() {
        let mockWeatherData = WeatherDisplayData(
            cityName: "Hanoi",
            temperature: "38°",
            description: "Mostly clear",
            high: "40°",
            low: "36°",
            icon: WeatherImages.morningSunny
        )
        
        updateUI(with: mockWeatherData)
    }
    
    private func updateUI(with data: WeatherDisplayData) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateUI(with: data)
            }
            return
        }
        
        currentWeatherData = data
        
        cityNameLabel.text = data.cityName
        mainTemperatureLabel.text = data.temperature
        weatherDescriptionLabel.text = data.description
        highLowTemperatureLabel.text = "H:\(data.high) L:\(data.low)"
        
        if let iconImage = UIImage(named: data.icon) {
            weatherIconImageView.image = iconImage
        } else {
            weatherIconImageView.image = UIImage(named: WeatherImages.morningSunny)
        }
        
        collectionView.reloadData()
    }
    
    private func updateCollectionViewDataSource() {
        if hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 {
            collectionView.dataSource = hourlyDataSource
            collectionView.delegate = hourlyDataSource
        } else {
            collectionView.dataSource = dailyDataSource
            collectionView.delegate = dailyDataSource
        }
        collectionView.reloadData()
    }
    
    private func refreshWeatherDataIfNeeded() {
        if currentWeatherData == nil {
            loadInitialData()
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        updateCollectionViewDataSource()
    }
    
    @objc private func handlePullToRefresh() {
        if let selectedCity = selectedCityLocation {
            loadWeatherForSelectedCity(selectedCity)
        } else if let location = locationManager.getCurrentLocation() {
            loadWeatherForLocation(location)
        } else {
            requestLocationAndLoadWeather()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func refreshWeatherData() {
        guard !isLoading else {
            collectionView.refreshControl?.endRefreshing()
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadMockWeatherData()
            self.isLoading = false
            self.collectionView.refreshControl?.endRefreshing()
            self.showSuccessMessage("Weather updated")
        }
    }
}

// MARK: - LocationManagerDelegate
extension HomeViewController: LocationManagerDelegate {
    
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        loadWeatherForLocation(location)
    }
    
    func locationManager(_ manager: LocationManager, didFailWithError error: LocationError) {
        hideLoading()
        
        let errorMessage: String
        switch error {
        case .permissionDenied:
            errorMessage = "Location access denied. Please enable location services in Settings to see weather for your current location."
        case .locationNotFound:
            errorMessage = "Unable to determine your location. Please try again."
        case .networkError:
            errorMessage = "Network error while getting location."
        case .serviceUnavailable:
            errorMessage = "Location services are not available."
        default:
            errorMessage = "Failed to get your location."
        }
        
        showErrorAlert(message: errorMessage) { [weak self] in
            self?.loadFallbackData()
        }
    }
    
    func locationManager(_ manager: LocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                manager.requestCurrentLocation()
            }
        case .denied, .restricted:
            loadFallbackData()
        default:
            break
        }
    }
}

// MARK: - ForecastDataSourceDelegate
extension HomeViewController: ForecastDataSourceDelegate {
    
    func didSelectHourlyForecast(_ forecast: HourlyDisplayData, at index: Int) {
        if !hourlyDataSource.hourlyForecasts.isEmpty && index < hourlyDataSource.hourlyForecasts.count {
            let hourlyItem = hourlyDataSource.hourlyForecasts[index]
            showDetailAlert(
                title: "Hourly Forecast",
                message: "\(hourlyItem.timeString): \(hourlyItem.temperatureString)\n\(hourlyItem.description.capitalized)"
            )
        } else {
            showDetailAlert(title: "Hourly Forecast", message: "\(forecast.time): \(forecast.temperature)")
        }
    }
    
    func didSelectDailyForecast(_ forecast: WeeklyDisplayData, at index: Int) {
        if !dailyDataSource.dailyForecasts.isEmpty && index < dailyDataSource.dailyForecasts.count {
            let dailyItem = dailyDataSource.dailyForecasts[index]
            showDetailAlert(
                title: "Daily Forecast",
                message: "\(dailyItem.dayString)\nHigh: \(String(format: "%.0f°", dailyItem.maxTemperature))\nLow: \(String(format: "%.0f°", dailyItem.minTemperature))\n\(dailyItem.description.capitalized)"
            )
        } else {
            showDetailAlert(title: "Daily Forecast", message: "\(forecast.day): \(forecast.high)/\(forecast.low)")
        }
    }
}