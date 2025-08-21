//
//  FavoritesViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

class FavoritesViewController: BaseViewController {
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    var favoritesList: [FavoriteCity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupTableView()
        setupCustomHeader()
        setupPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupUI() {
        addGradientBackground()
    }
    
    private func setupTableView() {
        favoritesTableView.dataSource = self
        favoritesTableView.delegate = self
        favoritesTableView.backgroundColor = .clear
        favoritesTableView.separatorStyle = .none
        favoritesTableView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 30, right: 0)
        favoritesTableView.showsVerticalScrollIndicator = false
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        favoritesTableView.refreshControl = refreshControl
    }
    
    @objc private func handlePullToRefresh() {
        refreshAllWeatherData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.favoritesTableView.refreshControl?.endRefreshing()
            self.showSuccessMessage("Weather data updated")
        }
    }
    
    private func setupCustomHeader() {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        backButton.layer.cornerRadius = 20
        
        let titleLabel = UILabel()
        titleLabel.text = "Favorites"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        
        let editButton = UIButton(type: .system)
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        editButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        editButton.layer.cornerRadius = 15
        editButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(editButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            editButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
}
