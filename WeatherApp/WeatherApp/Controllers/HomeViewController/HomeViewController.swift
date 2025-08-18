//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var mainTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var highLowTemperatureLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var hourlyWeeklySegmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var currentWeatherData: WeatherDisplayData?
    
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
        loadInitialData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshWeatherDataIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideLoading()
    }
    
    deinit {
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
        hourlyWeeklySegmentedControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
    }
    
    private func setupLabels() {
        cityNameLabel.text = ""
        mainTemperatureLabel.text = "--°"
        weatherDescriptionLabel.text = "Loading..."
        highLowTemperatureLabel.text = "H:--° L:--°"
    }
    
    private func setupImageViews() {
        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.image = UIImage(systemName: "cloud")
        weatherIconImageView.tintColor = .white
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
            flowLayout.minimumInteritemSpacing = 8
            flowLayout.minimumLineSpacing = 20
            flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        }
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func loadInitialData() {
        showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadMockWeatherData()
            self.hideLoading()
        }
    }
    
    private func loadMockWeatherData() {
        let mockWeatherData = WeatherDisplayData(
            cityName: "Hanoi",
            temperature: "38°",
            description: "Mostly clear",
            high: "40°",
            low: "36°",
            icon: "nightrain"
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
            weatherIconImageView.image = UIImage(systemName: "cloud")
        }
        
        collectionView.reloadData()
    }
    
    private func refreshWeatherDataIfNeeded() {
        if currentWeatherData == nil {
            loadInitialData()
        }
    }
    
    private func reloadCollectionViewData() {
        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve) {
            self.collectionView.reloadData()
        }
    }
    
    @objc private func segmentValueChanged(_ sender: UISegmentedControl) {
        reloadCollectionViewData()
    }
    
    @objc private func handlePullToRefresh() {
        refreshWeatherData()
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
