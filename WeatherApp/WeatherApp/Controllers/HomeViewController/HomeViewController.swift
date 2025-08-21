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
    private var currentLocation: CLLocation?
    var hourlyForecastData: [HourlyForecast] = []
    var dailyForecastData: [DailyForecast] = []
    
    let hourlyData = [
        HourlyDisplayData(time: "Now", temperature: "38°", icon: "sun.max"),
        HourlyDisplayData(time: "18h", temperature: "36°", icon: "cloud.sun"),
        HourlyDisplayData(time: "20h", temperature: "34°", icon: "cloud"),
        HourlyDisplayData(time: "22h", temperature: "32°", icon: "moon")
    ]
    
    let weeklyData = [
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
        setupLocationService()
        loadInitialData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestLocationAndLoadWeather()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideLoading()
    }
    
    deinit {
        collectionView?.delegate = nil
        collectionView?.dataSource = nil
        LocationService.shared.delegate = nil
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
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumInteritemSpacing = 35
            flowLayout.minimumLineSpacing = 35
            flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        }
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupLocationService() {
        LocationService.shared.delegate = self
    }
    
    private func loadInitialData() {
        showLoading()
        requestLocationAndLoadWeather()
    }
    
    private func requestLocationAndLoadWeather() {
        guard !isLoading else { return }
        
        weatherDescriptionLabel.text = "Getting your location..."
        
        if LocationService.shared.hasLocationPermission {
            LocationService.shared.requestCurrentLocation()
        } else {
            LocationService.shared.requestLocationPermission()
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
                    self?.hourlyForecastData = hourlyForecasts
                    self?.dailyForecastData = dailyForecasts
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("Failed to load forecast: \(error)")
                }
                self?.hideLoading()
            }
        }
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
    
    @IBAction func segmentChanged(_ sender: Any) {
        collectionView.reloadData()
    }
    
    @objc private func handlePullToRefresh() {
        if let location = currentLocation {
            loadWeatherForLocation(location)
        } else {
            requestLocationAndLoadWeather()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}

extension HomeViewController: LocationServiceDelegate {
    
    func locationService(_ service: LocationService, didUpdateLocation location: CLLocation) {
        currentLocation = location
        loadWeatherForLocation(location)
    }
    
    func locationService(_ service: LocationService, didFailWithError error: LocationError) {
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
    
    func locationServiceDidChangePermission(_ service: LocationService, status: CLAuthorizationStatus) {
        print("Permission status changed: \(status.rawValue)")
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                service.requestCurrentLocation()
            }
        case .denied, .restricted:
            loadFallbackData()
        default:
            break
        }
    }
}
