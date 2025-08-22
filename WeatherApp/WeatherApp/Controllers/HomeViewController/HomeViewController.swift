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
        collectionView?.delegate = nil
        collectionView?.dataSource = nil
    }
    
    // MARK: - Setup
    
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
        hourlyDataSource.delegate = self
        dailyDataSource.delegate = self
        updateCollectionViewDataSource()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func cleanupResources() {
        locationManager.delegate = nil
    }
    
    // MARK: - Data Flow
    
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
    
    private func handleInitialDataLoad() {
        if selectedCityLocation == nil && selectedWeatherData == nil {
            requestLocationAndLoadWeather()
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
    
    // MARK: - Update UI
    
    private func updateUI(with data: WeatherDisplayData) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.updateUI(with: data) }
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
            weatherIconImageView.image = UIImage(named: WeatherImages.morningSunny)
        }
    }
    
    private func updateCollectionViewDataSource() {
        let isHourly = hourlyWeeklySegmentedControl.selectedSegmentIndex == 0
        collectionView.dataSource = isHourly ? hourlyDataSource : dailyDataSource
        collectionView.delegate = isHourly ? hourlyDataSource : dailyDataSource
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
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
            self.showSuccessMessage("Weather updated")
        }
    }
}
