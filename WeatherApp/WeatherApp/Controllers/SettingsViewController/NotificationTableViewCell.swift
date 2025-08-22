//
//  NotificationTableViewCell.swift
//  WeatherApp
//
//  Created by Phan Quyen on 21/08/2025.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func didToggleNotification(_ isEnabled: Bool)
}

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    weak var delegate: NotificationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        titleLabel.text = "Notifications"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        
        notificationSwitch.onTintColor = UIColor.systemGreen
    }
    
    func configure(isEnabled: Bool) {
        notificationSwitch.isOn = isEnabled
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        delegate?.didToggleNotification(sender.isOn)
    }
}
