//
//  CacheService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation
import SQLite3

class CacheService {
    static let shared = CacheService()
    
    private var db: OpaquePointer?
    private let cacheQueue = DispatchQueue(label: "com.weatherapp.cache", qos: .utility)
    
    private init() {
        setupDatabase()
    }
    
    deinit {
        closeDatabase()
    }
    
    private func setupDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("WeatherCache.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            createTable()
        } else {
            print("Failed to open database")
        }
    }
    
    private func createTable() {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS weather_cache(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cache_key TEXT UNIQUE,
            data BLOB,
            timestamp INTEGER,
            expiry_time INTEGER);
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) != SQLITE_OK {
            print("Failed to create table")
        }
    }
    
    func saveData(key: String, data: Data, expiryMinutes: Int = 10) {
        cacheQueue.async {
            let insertSQL = "INSERT OR REPLACE INTO weather_cache (cache_key, data, timestamp, expiry_time) VALUES (?, ?, ?, ?)"
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(self.db, insertSQL, -1, &statement, nil) == SQLITE_OK {
                let timestamp = Int64(Date().timeIntervalSince1970)
                let expiry = timestamp + Int64(expiryMinutes * 60)
                
                sqlite3_bind_text(statement, 1, key, -1, nil)
                sqlite3_bind_blob(statement, 2, data.withUnsafeBytes { $0.bindMemory(to: UInt8.self).baseAddress }, Int32(data.count), nil)
                sqlite3_bind_int64(statement, 3, timestamp)
                sqlite3_bind_int64(statement, 4, expiry)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Cache saved: \(key)")
                }
            }
            
            sqlite3_finalize(statement)
        }
    }
    
    func getData(key: String, completion: @escaping (Data?) -> Void) {
        cacheQueue.async {
            let querySQL = "SELECT data, expiry_time FROM weather_cache WHERE cache_key = ?"
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, key, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_ROW {
                    let expiryTime = sqlite3_column_int64(statement, 1)
                    let currentTime = Int64(Date().timeIntervalSince1970)
                    
                    if currentTime < expiryTime {
                        if let dataPointer = sqlite3_column_blob(statement, 0) {
                            let dataSize = sqlite3_column_bytes(statement, 0)
                            let data = Data(bytes: dataPointer, count: Int(dataSize))
                            
                            DispatchQueue.main.async {
                                completion(data)
                            }
                            sqlite3_finalize(statement)
                            return
                        }
                    } else {
                        self.deleteExpiredCache(key: key)
                    }
                }
            }
            
            sqlite3_finalize(statement)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    func clearExpiredCache() {
        cacheQueue.async {
            let currentTime = Int64(Date().timeIntervalSince1970)
            let deleteSQL = "DELETE FROM weather_cache WHERE expiry_time < ?"
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(self.db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int64(statement, 1, currentTime)
                sqlite3_step(statement)
            }
            
            sqlite3_finalize(statement)
        }
    }
    
    private func deleteExpiredCache(key: String) {
        let deleteSQL = "DELETE FROM weather_cache WHERE cache_key = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, key, -1, nil)
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    func clearAllCache() {
        cacheQueue.async {
            let deleteSQL = "DELETE FROM weather_cache"
            sqlite3_exec(self.db, deleteSQL, nil, nil, nil)
        }
    }
    
    private func closeDatabase() {
        if db != nil {
            sqlite3_close(db)
            db = nil
        }
    }
}
