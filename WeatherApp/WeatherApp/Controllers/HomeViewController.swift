//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

class HomeViewController: BaseViewController {
    
    private let testButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test API", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
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
        view.addSubview(testButton)
        view.addSubview(resultLabel)
        
        testButton.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            testButton.widthAnchor.constraint(equalToConstant: 200),
            testButton.heightAnchor.constraint(equalToConstant: 50),
            
            resultLabel.topAnchor.constraint(equalTo: testButton.bottomAnchor, constant: 30),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func testButtonTapped() {
        testButton.isEnabled = false
        resultLabel.text = "Đang test API..."
        showLoading()
        
        WeatherService.shared.getCurrentWeather(cityName: "Ho Chi Minh City") { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                self?.testButton.isEnabled = true
                
                switch result {
                case .success(let weatherData):
                    self?.resultLabel.text = """
                    Thành phố: \(weatherData.cityName)
                    Nhiệt độ: \(weatherData.temperatureString)
                    Mô tả: \(weatherData.description)
                    Độ ẩm: \(weatherData.humidityString)
                    Tốc độ gió: \(weatherData.windString)
                    """
                case .failure(let error):
                    self?.resultLabel.text = "Lỗi API: \(error.localizedDescription)"
                }
            }
        }
    }
}
