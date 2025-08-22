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
            NotificationManager.shared.requestPermission { [weak self] granted in
                if granted {
                    self?.showSuccessAlert(message: "Notification permission granted")
                    self?.scheduleNotifications()
                } else {
                    self?.isNotificationEnabled = false
                    self?.saveSettings()
                    self?.showErrorAlert(message: "Please enable notifications in Settings app")
                    self?.settingsTableView.reloadData()
                }
            }
        } else {
            NotificationManager.shared.removeAllNotifications()
        }
        
        settingsTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    private func requestLocationPermission() {
        showSuccessAlert(message: "Location permission requested")
    }
    
    private func scheduleNotifications() {
        if isNotificationEnabled && !selectedDays.isEmpty {
            NotificationManager.shared.scheduleDailyWeatherNotification(at: notificationTime, for: selectedDays)
        }
    }
    
    func showNotificationTimePicker() {
        let alert = UIAlertController(title: "Set Notification Time", message: "\n\n\n\n\n", preferredStyle: .alert)
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        timePicker.date = notificationTime
        timePicker.translatesAutoresizingMaskIntoConstraints = false
 
        alert.view.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            timePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            timePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 70)
        ])
        
        alert.addAction(UIAlertAction(title: "Set Time", style: .default) { [weak self] _ in
            self?.notificationTime = timePicker.date
            self?.saveSettings()
            self?.scheduleNotifications()
            self?.settingsTableView.reloadData()
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            self?.showSuccessAlert(message: "Notification time set to \(formatter.string(from: timePicker.date))")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
                self?.scheduleNotifications()
                self?.settingsTableView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel) { [weak self] _ in
            if let selectedDays = self?.selectedDays, !selectedDays.isEmpty {
                self?.showSuccessAlert(message: "Daily notifications have been scheduled!")
            }
        })
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
}
