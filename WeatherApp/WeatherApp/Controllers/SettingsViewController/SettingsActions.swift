//
//  SettingsActions.swift
//  WeatherApp
//
//  Created by Phan Quyen on 21/08/2025.
//

import UIKit

extension SettingsViewController: AutoLocationCellDelegate, NotificationCellDelegate {
    
    func didToggleAutomatedLocation(_ isEnabled: Bool) {
        isAutomatedLocationEnabled = isEnabled
        saveSettings()
        
        if isEnabled {
            requestLocationPermission()
        }
    }
    
    func didToggleNotification(_ isEnabled: Bool) {
        isNotificationEnabled = isEnabled
        saveSettings()
        
        if isEnabled {
            requestNotificationPermission()
        }
        
        settingsTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    private func requestLocationPermission() {
        // TODO: Implement CoreLocation permission request
        showSuccessMessage("Location permission requested")
    }
    
    private func requestNotificationPermission() {
        // TODO: Implement notification permission request
        showSuccessMessage("Notification permission requested")
    }
    
    func showNotificationTimePicker() {
        // Tạo alert với space cho date picker
        let alert = UIAlertController(title: "Set Notification Time", message: "\n\n\n\n\n", preferredStyle: .alert)
        
        // Tạo date picker
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        timePicker.date = notificationTime
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Thêm date picker vào alert view (KHÔNG dùng contentViewController)
        alert.view.addSubview(timePicker)
        
        // Set constraints
        NSLayoutConstraint.activate([
            timePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            timePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 70)
        ])
        
        // Thêm actions
        alert.addAction(UIAlertAction(title: "Set Time", style: .default) { [weak self] _ in
            self?.notificationTime = timePicker.date
            self?.saveSettings()
            self?.settingsTableView.reloadData()
            
            // Hiện day selection sau khi set time
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.showDaySelectionAlert()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showDaySelectionAlert() {
        let alert = UIAlertController(title: "Select Days", message: "Choose which days to receive notifications", preferredStyle: .actionSheet)
        
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        for (index, day) in days.enumerated() {
            let dayIndex = index + 1
            let isSelected = selectedDays.contains(dayIndex)
            let title = isSelected ? "✓ \(day)" : day
            
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                if isSelected {
                    self?.selectedDays.remove(dayIndex)
                } else {
                    self?.selectedDays.insert(dayIndex)
                }
                self?.saveSettings()
                self?.settingsTableView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
}
