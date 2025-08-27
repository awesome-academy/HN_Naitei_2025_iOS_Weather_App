//
//  NotificationManager.swift
//  WeatherApp
//
//  Created by Phan Quyen on 23/08/2025.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private var handledNotificationIdentifiers = Set<String>()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleDailyWeatherNotification(at time: Date, for days: Set<Int>) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for dayOfWeek in days {
            let identifier = "daily_weather_\(dayOfWeek)"
            
            var dateComponents = DateComponents()
            dateComponents.hour = Calendar.current.component(.hour, from: time)
            dateComponents.minute = Calendar.current.component(.minute, from: time)
            dateComponents.weekday = dayOfWeek
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let content = UNMutableNotificationContent()
            content.title = "Weather Update"
            content.body = "Tap to check current weather conditions"
            content.sound = .default
            content.badge = 1
            content.userInfo = ["shouldFetchWeather": true]
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Notification scheduled for weekday: \(dayOfWeek)")
                }
            }
        }
    }
    
    func scheduleWeatherNotificationWithData(location: String, temperature: String, condition: String) {
        let content = UNMutableNotificationContent()
        content.title = "Weather Update"
        content.body = "\(location) - \(temperature) - \(condition)"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "weather_now", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending weather notification: \(error)")
            }
        }
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Only handle the notification display, don't trigger weather fetch here to avoid duplicates
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.userInfo["shouldFetchWeather"] as? Bool == true {
            let identifier = response.notification.request.identifier

            if !handledNotificationIdentifiers.contains(identifier) {
                handledNotificationIdentifiers.insert(identifier)
                WeatherNotificationService.shared.sendCurrentWeatherNotification()

                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    self?.handledNotificationIdentifiers.remove(identifier)
                }
            }
        }
        
        print("User tapped notification")
        completionHandler()
    }
}
