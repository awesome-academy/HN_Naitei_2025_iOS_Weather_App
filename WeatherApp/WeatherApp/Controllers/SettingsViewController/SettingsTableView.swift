//
//  SettingsTableView.swift
//  WeatherApp
//
//  Created by Phan Quyen on 21/08/2025.
//

import UIKit

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return isNotificationEnabled ? 2 : 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoLocationCell", for: indexPath) as! AutoLocationTableViewCell
            cell.delegate = self
            cell.configure(isEnabled: isAutomatedLocationEnabled)
            return cell
            
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
                cell.delegate = self
                cell.configure(isEnabled: isNotificationEnabled)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTimeCell", for: indexPath) as! NotificationTimeTableViewCell
                cell.configure(time: notificationTime, days: selectedDays, isEnabled: isNotificationEnabled)
                return cell
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Location"
        case 1: return "Notifications"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .white.withAlphaComponent(0.7)
            header.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 1 && isNotificationEnabled {
            showNotificationTimePicker()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
