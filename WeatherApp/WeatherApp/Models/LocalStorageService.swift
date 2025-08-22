//
//  LocalStorageService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import Foundation

protocol LocalStorageServiceProtocol {
    func save<T>(_ value: T, forKey key: String)
    func load<T>(forKey key: String, type: T.Type) -> T?
    func loadBool(forKey key: String) -> Bool
    func loadString(forKey key: String) -> String?
    func loadData(forKey key: String) -> Data?
    func remove(forKey key: String)
    func clearAll()
}

class LocalStorageService: LocalStorageServiceProtocol {
    static let shared = LocalStorageService()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func save<T>(_ value: T, forKey key: String) {
        if let encodableValue = value as? Codable {
            do {
                let data = try JSONEncoder().encode(encodableValue)
                userDefaults.set(data, forKey: key)
            } catch {
                print("Failed to encode value for key \(key): \(error)")
            }
        } else {
            userDefaults.set(value, forKey: key)
        }
    }
    
    func load<T>(forKey key: String, type: T.Type) -> T? {
        if let data = userDefaults.data(forKey: key),
           let decodableType = type as? Decodable.Type {
            do {
                return try JSONDecoder().decode(decodableType, from: data) as? T
            } catch {
                print("Failed to decode value for key \(key): \(error)")
                return nil
            }
        }
        return userDefaults.object(forKey: key) as? T
    }
    
    func loadBool(forKey key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }
    
    func loadString(forKey key: String) -> String? {
        return userDefaults.string(forKey: key)
    }
    
    func loadData(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
    }
}

extension LocalStorageService {
    enum Keys {
        static let automatedLocationEnabled = "AutomatedLocationEnabled"
        static let notificationEnabled = "NotificationEnabled"
        static let notificationTime = "NotificationTime"
        static let selectedDays = "SelectedDays"
    }
}
