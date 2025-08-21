//
//  AutoLocationTableViewCell.swift
//  WeatherApp
//
//  Created by Phan Quyen on 21/08/2025.
//

import UIKit

protocol AutoLocationCellDelegate: AnyObject {
    func didToggleAutomatedLocation(_ isEnabled: Bool)
}

class AutoLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    
    weak var delegate: AutoLocationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        titleLabel.text = "Automated location"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        
        locationSwitch.onTintColor = UIColor.systemBlue
        locationSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    func configure(isEnabled: Bool) {
        locationSwitch.isOn = isEnabled
    }
    
    @objc private func switchValueChanged() {
        delegate?.didToggleAutomatedLocation(locationSwitch.isOn)
    }
}
