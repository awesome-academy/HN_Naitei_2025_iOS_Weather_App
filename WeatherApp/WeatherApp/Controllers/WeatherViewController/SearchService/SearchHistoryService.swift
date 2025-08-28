//
//  SearchHistoryService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 28/08/2025.
//

import Foundation

class SearchHistoryService {
    static let shared = SearchHistoryService()
    private let userDefaults = UserDefaults.standard
    private let maxHistoryCount = 10
    
    private enum Keys {
        static let searchHistory = "WeatherSearchHistory"
    }
    
    private init() {}
    
    func saveSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var history = getSearchHistory()
        
        history.removeAll { $0.lowercased() == trimmed.lowercased() }
        
        history.insert(trimmed, at: 0)
        
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        userDefaults.set(history, forKey: Keys.searchHistory)
    }
    
    func getSearchHistory() -> [String] {
        return userDefaults.stringArray(forKey: Keys.searchHistory) ?? []
    }
    
    func getFilteredHistory(for query: String) -> [String] {
        guard !query.isEmpty else { return [] }
        
        return getSearchHistory().filter { item in
            item.lowercased().contains(query.lowercased())
        }.prefix(5).map { $0 }
    }
    
    func clearHistory() {
        userDefaults.removeObject(forKey: Keys.searchHistory)
    }
}
