//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

class HomeViewController: BaseViewController {
    
    private lazy var testAPIButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test Weather API", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(testAPIButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Home appeared")
    }
    
    private func setupNavigationBar() {
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupUI() {
        view.addSubview(testAPIButton)
        
        NSLayoutConstraint.activate([
            testAPIButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testAPIButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            testAPIButton.widthAnchor.constraint(equalToConstant: 200),
            testAPIButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func testAPIButtonTapped() {
        showLoading()
        
        // Test current weather for Hanoi
        WeatherService.shared.getCurrentWeather(for: "Hanoi,VN") { [weak self] result in
            self?.hideLoading()
            
            switch result {
            case .success(let weatherData):
                let message = """
                City: \(weatherData.cityName)
                Temperature: \(weatherData.temperatureString)
                Description: \(weatherData.description)
                Humidity: \(weatherData.humidityString)
                Wind: \(weatherData.windString)
                """
                self?.showSuccess(title: "Weather Data", message: message)
                
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
}
