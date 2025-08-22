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
    
    var currentWeatherData: WeatherDisplayData?
    var selectedCityLocation: CityLocation?
    var selectedWeatherData: WeatherDisplayData?
    
    let locationManager = LocationManager.shared
    let hourlyDataSource = HourlyForecastDataSource()
    let dailyDataSource = DailyForecastDataSource()
    
    private let mockHourlyData = [
        HourlyDisplayData(time: "Now", temperature: "38°", icon: WeatherImages.morningSunny),
        HourlyDisplayData(time: "18h", temperature: "36°", icon: WeatherImages.morningSunny),
        HourlyDisplayData(time: "20h", temperature: "34°", icon: WeatherImages.nightWind),
        HourlyDisplayData(time: "22h", temperature: "32°", icon: WeatherImages.nightWind)
    ]
    
    private let mockWeeklyData = [
        WeeklyDisplayData(day: "Today", high: "38°", low: "25°", icon: WeatherImages.morningSunny),
        WeeklyDisplayData(day: "Tomorrow", high: "36°", low: "23°", icon: WeatherImages.morningSunny),
        WeeklyDisplayData(day: "Wed", high: "34°", low: "22°", icon: WeatherImages.morningLightRain),
        WeeklyDisplayData(day: "Thu", high: "32°", low: "20°", icon: WeatherImages.morningLightRain)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleInitialDataLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideLoading()
    }
    
    deinit {
        cleanupResources()
    }
    
    private func initializeViewController() {
        setupNavigationBar()
        setupUI()
        setupCollectionView()
        setupDataSources()
        setupLocationManager()
        setupPullToRefresh()
        setupForecastBackground()
        handleNavigationFromOtherViews()
    }
    
    private func handleInitialDataLoad() {
        if selectedCityLocation == nil && selectedWeatherData == nil {
            requestLocationAndLoadWeather()
        }
    }
    
    private func cleanupResources() {
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
        hourlyWeeklySegmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
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
            flowLayout.minimumInteritemSpacing = 8
            flowLayout.minimumLineSpacing = 20
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
    
    private func handleNavigationFromOtherViews() {
        if let selectedCity = selectedCityLocation {
            loadWeatherForSelectedCity(selectedCity)
        } else if let selectedWeather = selectedWeatherData {
            updateUI(with: selectedWeather)
            loadForecastForWeatherData(selectedWeather)
        } else {
            loadInitialData()
        }
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
    
    func loadWeatherForLocation(_ location: CLLocation) {
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
    
    private func loadForecastData(_ location: CLLocation) {
        WeatherRepository.shared.getForecast(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (hourlyForecasts, dailyForecasts)):
                    self?.updateForecastData(hourly: hourlyForecasts, daily: dailyForecasts)
                case .failure:
                    self?.useMockForecastData()
                }
                self?.hideLoading()
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
                case .failure:
                    self?.useMockForecastData()
                }
                self?.hideLoading()
            }
        }
    }
    
    private func loadForecastForWeatherData(_ weatherData: WeatherDisplayData) {
        if let city = getCityLocationFromWeatherData(weatherData) {
            loadForecastForSelectedCity(city)
        } else {
            useMockForecastData()
        }
    }
    
    private func updateForecastData(hourly: [HourlyForecast], daily: [DailyForecast]) {
        hourlyDataSource.hourlyForecasts = hourly
        dailyDataSource.dailyForecasts = daily
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
    }
    
    private func useMockForecastData() {
        hourlyDataSource.hourlyForecasts = []
        dailyDataSource.dailyForecasts = []
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func handleWeatherSuccess(_ weatherData: WeatherData) {
        let weatherIcon = WeatherImages.imageForWeatherData(weatherData)
        
        let displayData = WeatherDisplayData(
            cityName: "\(weatherData.cityName), \(weatherData.country)",
            temperature: weatherData.temperatureString,
            description: weatherData.description,
            high: String(format: "%.0f°", weatherData.temperature + 5),
            low: String(format: "%.0f°", weatherData.temperature - 5),
            icon: weatherIcon
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
    
    func loadFallbackData() {
        let fallbackData = WeatherDisplayData(
            cityName: "Current Location",
            temperature: "--°",
            description: "Weather unavailable",
            high: "--°",
            low: "--°",
            icon: WeatherImages.morningSunny
        )
        updateUI(with: fallbackData)
        useMockForecastData()
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
        
        updateWeatherIcon(iconName: data.icon)
        collectionView.reloadData()
    }
    
    private func updateWeatherIcon(iconName: String) {
        if let iconImage = UIImage(named: iconName) {
            weatherIconImageView.image = iconImage
        } else {
            let fallbackIcon = WeatherImages.morningSunny
            weatherIconImageView.image = UIImage(named: fallbackIcon)
        }
    }
    
    private func updateCollectionViewDataSource() {
        let isHourly = hourlyWeeklySegmentedControl.selectedSegmentIndex == 0
        
        if isHourly {
            collectionView.dataSource = hourlyDataSource
            collectionView.delegate = hourlyDataSource
        } else {
            collectionView.dataSource = dailyDataSource
            collectionView.delegate = dailyDataSource
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
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
    
    @objc private func segmentChanged(_ sender: Any) {
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
}
