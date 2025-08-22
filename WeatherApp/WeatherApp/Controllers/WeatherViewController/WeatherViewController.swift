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
    }
}
