//
//  ForecastCell.swift
//  WeatherApp
//
//  Created by Phan Quyen on 18/08/2025.
//

import UIKit

class ForecastCell: UICollectionViewCell {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        topLabel?.textColor = .white
        topLabel?.textAlignment = .center
        topLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        iconLabel?.textColor = .white
        iconLabel?.textAlignment = .center
        iconLabel?.font = UIFont.systemFont(ofSize: 24)
        
        bottomLabel?.textColor = .white
        bottomLabel?.textAlignment = .center
        bottomLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    }
    
    func configureHourly(with data: HourlyDisplayData) {
        topLabel?.text = data.time
        bottomLabel?.text = data.temperature
        iconLabel?.text = getWeatherIcon(for: data.icon)
    }
    
    func configureWeekly(with data: WeeklyDisplayData) {
        topLabel?.text = data.day
        bottomLabel?.text = "\(data.high)/\(data.low)"
        iconLabel?.text = getWeatherIcon(for: data.icon)
    }
    
    private func getWeatherIcon(for condition: String) -> String {
        switch condition {
        case "sun.max":
            return "○"
        case "cloud.sun":
            return "◐"
        case "cloud":
            return "●"
        case "cloud.rain":
            return "¤"
        case "moon":
            return "◑"
        case "snow":
            return "❋"
        default:
            return "○"
        }
    }
}
