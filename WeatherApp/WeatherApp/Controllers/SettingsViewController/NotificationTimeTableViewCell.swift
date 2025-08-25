//
//  NotificationTimeTableViewCell.swift
//  WeatherApp
//
//  Created by Phan Quyen on 21/08/2025.
//

import UIKit

class NotificationTimeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var notificationTime: Date = Date()
    private var selectedDays: Set<Int> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .default
        
        titleLabel.text = "Daily Notification"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        timeLabel.textAlignment = .right
    }
    
    func configure(time: Date, days: Set<Int>, isEnabled: Bool) {
        notificationTime = time
        selectedDays = days
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        let daysString = formatSelectedDays(days)
        timeLabel.text = "\(timeFormatter.string(from: time)) • \(daysString)"
        
        titleLabel.textColor = isEnabled ? .white : .white.withAlphaComponent(0.5)
        timeLabel.textColor = isEnabled ? .white.withAlphaComponent(0.8) : .white.withAlphaComponent(0.3)
        
        isUserInteractionEnabled = isEnabled
    }
    
    private func formatSelectedDays(_ days: Set<Int>) -> String {
        if days.count == 7 {
            return "Every day"
        } else if days.count == 5 && !days.contains(1) && !days.contains(7) {
            return "Weekdays"
        } else if days.count == 2 && days.contains(1) && days.contains(7) {
            return "Weekends"
        } else {
            let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let selectedNames = days.sorted().map { dayNames[$0 - 1] }
            return selectedNames.joined(separator: ", ")
        }
    }
}
