//
//  ForecastCell.swift
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
    
    private func setupUI() {
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
        iconLabel?.text = data.weatherIcon
    }
    
    func configureWeekly(with data: WeeklyDisplayData) {
        topLabel?.text = data.day
        bottomLabel?.text = "\(data.high)/\(data.low)"
        iconLabel?.text = data.weatherIcon
    }
}
