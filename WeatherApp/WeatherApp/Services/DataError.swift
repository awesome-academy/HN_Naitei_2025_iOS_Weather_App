//
//  DataError.swift
//  WeatherApp
//
//  Created by Phan Quyen on 14/08/2025.
//

import Foundation

enum DataError: Error {
    case duplicateEntry
    case notFound
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    case contextNotAvailable
    
    var localizedDescription: String {
        switch self {
        case .duplicateEntry:
            return "City already exists in favorites"
        case .notFound:
            return "City not found"
        case .saveFailed(let error):
            return "Save failed: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Delete failed: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Fetch failed: \(error.localizedDescription)"
        case .contextNotAvailable:
            return "Data context not available"
        }
    }
}
