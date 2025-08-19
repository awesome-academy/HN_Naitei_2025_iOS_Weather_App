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
        loadSampleData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Weather view appeared")
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
        citySearchBar.backgroundImage = UIImage()
        citySearchBar.backgroundColor = .clear
        citySearchBar.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        citySearchBar.searchTextField.layer.cornerRadius = 12
        citySearchBar.searchTextField.textColor = .darkGray
        citySearchBar.searchTextField.font = UIFont.systemFont(ofSize: 16)
    }
    
    private func setupTableView() {
        weatherTableView.dataSource = self
        weatherTableView.delegate = self
        weatherTableView.backgroundColor = .clear
        weatherTableView.separatorStyle = .none
        weatherTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        weatherTableView.showsVerticalScrollIndicator = false
    }
}

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell
        cell.configure(with: weatherDataList[indexPath.row])
        
        if indexPath.row == weatherDataList.count - 1 {
            loadMoreDataIfNeeded()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let availableHeight = screenHeight - 200
        return (availableHeight / 4.5) - 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = weatherDataList[indexPath.row]
        showDetailAlert(title: "Weather Info", message: "\(selectedCity.cityName): \(selectedCity.temperature)")
    }
}
