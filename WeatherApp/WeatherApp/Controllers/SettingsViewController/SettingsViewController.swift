//
//  SettingsViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

//
//  SettingsViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

class SettingsViewController: BaseViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    var isAutomatedLocationEnabled = false
    var isNotificationEnabled = false
    var notificationTime = Date()
    var selectedDays: Set<Int> = [1, 2, 3, 4, 5]
    
    private let localStorage = LocalStorageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupTableView()
        loadSettings()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupUI() {
        addGradientBackground()
        setupCustomHeader()
    }
    
    private func setupTableView() {
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        settingsTableView.backgroundColor = .clear
        settingsTableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 30, right: 0)
        settingsTableView.showsVerticalScrollIndicator = false
    }
    
    private func setupCustomHeader() {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
    
    func loadSettings() {
        isAutomatedLocationEnabled = localStorage.loadBool(forKey: LocalStorageService.Keys.automatedLocationEnabled)
        isNotificationEnabled = localStorage.loadBool(forKey: LocalStorageService.Keys.notificationEnabled)
        
        if let timeData = localStorage.loadData(forKey: LocalStorageService.Keys.notificationTime),
           let savedTime = try? JSONDecoder().decode(Date.self, from: timeData) {
            notificationTime = savedTime
        }
        
        if let daysArray = localStorage.load(forKey: LocalStorageService.Keys.selectedDays, type: [Int].self) {
            selectedDays = Set(daysArray)
        }
        
        settingsTableView.reloadData()
    }
    
    func saveSettings() {
        localStorage.save(isAutomatedLocationEnabled, forKey: LocalStorageService.Keys.automatedLocationEnabled)
        localStorage.save(isNotificationEnabled, forKey: LocalStorageService.Keys.notificationEnabled)
        localStorage.save(notificationTime, forKey: LocalStorageService.Keys.notificationTime)
        localStorage.save(Array(selectedDays), forKey: LocalStorageService.Keys.selectedDays)
    }
}
