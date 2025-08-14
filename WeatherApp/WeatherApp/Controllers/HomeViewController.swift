import UIKit

struct WeatherDisplayData {
    let cityName: String
    let temperature: String
    let description: String
    let high: String
    let low: String
    let icon: String
}

struct HourlyDisplayData {
    let time: String
    let temperature: String
    let icon: String
}

struct WeeklyDisplayData {
    let day: String
    let high: String
    let low: String
    let icon: String
}

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var mainTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var highLowTemperatureLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var hourlyWeeklySegmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    private var isLoading = false
    private var currentWeatherData: WeatherDisplayData?
    
    private let hourlyData = [
        HourlyDisplayData(time: "Now", temperature: "38°", icon: "sun.max"),
        HourlyDisplayData(time: "17h", temperature: "37°", icon: "sun.max"),
        HourlyDisplayData(time: "18h", temperature: "36°", icon: "cloud.sun"),
        HourlyDisplayData(time: "19h", temperature: "35°", icon: "cloud.sun"),
        HourlyDisplayData(time: "20h", temperature: "34°", icon: "cloud"),
        HourlyDisplayData(time: "21h", temperature: "33°", icon: "cloud"),
        HourlyDisplayData(time: "22h", temperature: "32°", icon: "moon"),
        HourlyDisplayData(time: "23h", temperature: "31°", icon: "moon")
    ]
    
    private let weeklyData = [
        WeeklyDisplayData(day: "Today", high: "38°", low: "25°", icon: "sun.max"),
        WeeklyDisplayData(day: "Tomorrow", high: "36°", low: "23°", icon: "cloud.sun"),
        WeeklyDisplayData(day: "Wednesday", high: "34°", low: "22°", icon: "cloud.rain"),
        WeeklyDisplayData(day: "Thursday", high: "32°", low: "20°", icon: "cloud.rain"),
        WeeklyDisplayData(day: "Friday", high: "35°", low: "24°", icon: "cloud.sun"),
        WeeklyDisplayData(day: "Saturday", high: "37°", low: "26°", icon: "sun.max"),
        WeeklyDisplayData(day: "Sunday", high: "39°", low: "27°", icon: "sun.max")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupCollectionView()
        setupPullToRefresh()
        loadInitialData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Home appeared")
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
            print("Error: CollectionView outlet not connected")
            return
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumInteritemSpacing = 8
            flowLayout.minimumLineSpacing = 12
            flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
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
    override func showLoading() {
        guard !isLoading else { return }
        isLoading = true
        super.showLoading()
    }
    
    override func hideLoading() {
        isLoading = false
        super.hideLoading()
    }
    
    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
        }
    }
    
    private func showDetailAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func configureCell(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 {
            configureHourlyCell(cell, with: hourlyData[indexPath.item])
        } else {
            configureWeeklyCell(cell, with: weeklyData[indexPath.item])
        }
    }
    
    private func configureHourlyCell(_ cell: UICollectionViewCell, with data: HourlyDisplayData) {
        let timeLabel = createLabel(text: data.time, font: UIFont.systemFont(ofSize: 12, weight: .medium))
        let tempLabel = createLabel(text: data.temperature, font: UIFont.systemFont(ofSize: 14, weight: .bold))
        let iconImageView = createImageView(systemName: data.icon)
        
        cell.contentView.addSubview(timeLabel)
        cell.contentView.addSubview(iconImageView)
        cell.contentView.addSubview(tempLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            timeLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            tempLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            tempLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            tempLabel.bottomAnchor.constraint(lessThanOrEqualTo: cell.contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func configureWeeklyCell(_ cell: UICollectionViewCell, with data: WeeklyDisplayData) {
        let dayLabel = createLabel(text: data.day, font: UIFont.systemFont(ofSize: 10, weight: .medium))
        let tempLabel = createLabel(text: "\(data.high)/\(data.low)", font: UIFont.systemFont(ofSize: 12, weight: .bold))
        let iconImageView = createImageView(systemName: data.icon)
        
        cell.contentView.addSubview(dayLabel)
        cell.contentView.addSubview(iconImageView)
        cell.contentView.addSubview(tempLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            dayLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            tempLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            tempLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            tempLabel.bottomAnchor.constraint(lessThanOrEqualTo: cell.contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func createLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createImageView(systemName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemName)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 ? hourlyData.count : weeklyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath)
        
        configureCell(cell, at: indexPath)
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if hourlyWeeklySegmentedControl.selectedSegmentIndex == 0 {
            let hourlyItem = hourlyData[indexPath.item]
            print("Selected hour: \(hourlyItem.time) - \(hourlyItem.temperature)")
            showDetailAlert(title: "Hourly Forecast", message: "\(hourlyItem.time): \(hourlyItem.temperature)")
        } else {
            let weeklyItem = weeklyData[indexPath.item]
            print("Selected day: \(weeklyItem.day) - \(weeklyItem.high)/\(weeklyItem.low)")
            showDetailAlert(title: "Daily Forecast", message: "\(weeklyItem.day): \(weeklyItem.high)/\(weeklyItem.low)")
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
}
