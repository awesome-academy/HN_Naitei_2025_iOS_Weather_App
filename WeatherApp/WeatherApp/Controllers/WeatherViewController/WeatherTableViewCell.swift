//
//  WeatherTableViewCell.swift
//  WeatherApp
//
//  Created by Phan Quyen on 19/08/2025.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: WeatherTableViewCellDelegate?
    private var currentWeatherData: WeatherDisplayData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor(red: 0.45, green: 0.35, blue: 0.85, alpha: 0.6)
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 4
        
        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.backgroundColor = .clear
        
        temperatureLabel.textColor = .white
        temperatureLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        
        cityLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        cityLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        setupFavoriteButton()
    }
    
    private func setupFavoriteButton() {
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = .white
        favoriteButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        favoriteButton.layer.cornerRadius = 15
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    func configure(with data: WeatherDisplayData) {
        currentWeatherData = data
        temperatureLabel.text = data.temperature
        cityLabel.text = data.cityName

        let imageName = WeatherImages.imageForWeatherData(data)
        weatherIconImageView.image = UIImage(named: imageName)
        
        checkFavoriteStatus(for: data.cityName)
    }
    
    private func checkFavoriteStatus(for cityName: String) {
        DataManager.shared.getAllFavorites { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let favorites):
                    let isFavorite = favorites.contains { favorite in
                        favorite.displayName.lowercased().contains(cityName.lowercased().components(separatedBy: ",").first ?? "")
                    }
                    self?.favoriteButton.isSelected = isFavorite
                case .failure:
                    self?.favoriteButton.isSelected = false
                }
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {
        guard let weatherData = currentWeatherData else { return }
        
        if favoriteButton.isSelected {
            delegate?.didTapRemoveFavorite(weatherData)
        } else {
            delegate?.didTapAddFavorite(weatherData)
        }
    }
}

protocol WeatherTableViewCellDelegate: AnyObject {
    func didTapAddFavorite(_ weatherData: WeatherDisplayData)
    func didTapRemoveFavorite(_ weatherData: WeatherDisplayData)
}
