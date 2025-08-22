//
//  ForecastCollectionCell.swift
//  WeatherApp
//
//  Created by Phan Quyen on 18/08/2025.
//

import UIKit

class ForecastCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topLabel?.text = ""
        iconLabel?.text = ""
        bottomLabel?.text = ""
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        topLabel?.textColor = .white
        topLabel?.textAlignment = .center
        topLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        
        iconLabel?.textColor = .white
        iconLabel?.textAlignment = .center
        iconLabel?.font = .systemFont(ofSize: 24)
        
        bottomLabel?.textColor = .white
        bottomLabel?.textAlignment = .center
        bottomLabel?.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    func configureHourly(with data: HourlyDisplayData) {
        topLabel?.text = data.time
        bottomLabel?.text = data.temperature
        iconLabel?.text = getWeatherSymbol(for: data.icon)
    }
    
    func configureWeekly(with data: WeeklyDisplayData) {
        topLabel?.text = data.day
        bottomLabel?.text = "\(data.high)/\(data.low)"
        iconLabel?.text = getWeatherSymbol(for: data.icon)
    }
    
    private func getWeatherSymbol(for icon: String) -> String {
        switch icon {
        case WeatherImages.morningSunny:
            return "☀"
        case WeatherImages.nightWind:
            return "☽"
        case WeatherImages.morningLightRain:
            return "🌧"
        case WeatherImages.morningHeavyRain:
            return "⛈"
        case WeatherImages.nightRain:
            return "🌧"
        case WeatherImages.tornado:
            return "⚡"
        default:
            return "☀"
        }
    }
}
