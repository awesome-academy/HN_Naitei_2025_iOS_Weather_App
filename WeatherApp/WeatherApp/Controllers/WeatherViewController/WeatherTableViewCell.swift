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
        temperatureLabel.font = UIFont.systemFont(ofSize: 35, weight: .light)
        
        cityLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        cityLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    func configure(with data: WeatherDisplayData) {
        temperatureLabel.text = data.temperature
        cityLabel.text = data.cityName
        
        let imageName = WeatherImages.randomImage()
        weatherIconImageView.image = UIImage(named: imageName)
    }
}
