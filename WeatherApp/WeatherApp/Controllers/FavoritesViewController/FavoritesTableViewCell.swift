//
//  FavoritesTableViewCell.swift
//  WeatherApp
//
//  Created by Phan Quyen on 20/08/2025.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 0.8)
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 8
        
        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.backgroundColor = .clear
        weatherIconImageView.layer.cornerRadius = 25
        weatherIconImageView.layer.masksToBounds = false
        
        temperatureLabel.textColor = .white
        temperatureLabel.font = UIFont.systemFont(ofSize: 28, weight: .light)
        temperatureLabel.textAlignment = .left
        
        cityLabel.textColor = .white
        cityLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cityLabel.textAlignment = .left
        cityLabel.numberOfLines = 2
        
        coordinatesLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        coordinatesLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        coordinatesLabel.textAlignment = .left
    }
    
    func configure(with favorite: FavoriteCity, weatherData: WeatherDisplayData? = nil) {
        cityLabel.text = favorite.displayName
        coordinatesLabel.text = favorite.coordinatesString
        
        if let weather = weatherData {
            temperatureLabel.text = weather.temperature
            weatherIconImageView.image = UIImage(named: weather.icon)
        } else {
            temperatureLabel.text = "--°"
            weatherIconImageView.image = UIImage(named: WeatherImages.morningSunny)
        }
    }
}
