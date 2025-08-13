//
//  DataManager.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import CoreData
import Foundation
import UIKit

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    private var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    private var backgroundContext: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer.newBackgroundContext()
    }
    
    func saveFavorite(cityLocation: CityLocation, completion: @escaping (Result<Bool, DataError>) -> Void) {
        let bgContext = backgroundContext
        
        DispatchQueue.global(qos: .utility).async {
            bgContext.perform {
                if self.favoriteExistsInContext(cityLocation: cityLocation, context: bgContext) {
                    DispatchQueue.main.async {
                        completion(.failure(.duplicateEntry))
                    }
                    return
                }
                
                let _ = FavoriteCity(from: cityLocation, in: bgContext)
                
                do {
                    try bgContext.save()
                    DispatchQueue.main.async {
                        completion(.success(true))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.saveFailed(error)))
                    }
                }
            }
        }
    }
    
    func removeFavorite(cityLocation: CityLocation, completion: @escaping (Result<Bool, DataError>) -> Void) {
        let bgContext = backgroundContext
        
        DispatchQueue.global(qos: .utility).async {
            bgContext.perform {
                let request: NSFetchRequest<FavoriteCity> = FavoriteCity.fetchRequest()
                request.predicate = NSPredicate(format: "name == %@ AND country == %@",
                                                cityLocation.name, cityLocation.country)
                
                do {
                    let favorites = try bgContext.fetch(request)
                    guard !favorites.isEmpty else {
                        DispatchQueue.main.async {
                            completion(.failure(.notFound))
                        }
                        return
                    }
                    
                    for favorite in favorites {
                        bgContext.delete(favorite)
                    }
                    
                    try bgContext.save()
                    DispatchQueue.main.async {
                        completion(.success(true))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.deleteFailed(error)))
                    }
                }
            }
        }
    }
    
    func getAllFavorites(completion: @escaping (Result<[FavoriteCity], DataError>) -> Void) {
        let context = self.context
        
        DispatchQueue.global(qos: .userInitiated).async {
            context.perform {
                let request: NSFetchRequest<FavoriteCity> = FavoriteCity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteCity.dateAdded, ascending: false)]
                
                do {
                    let favorites = try context.fetch(request)
                    DispatchQueue.main.async {
                        completion(.success(favorites))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.fetchFailed(error)))
                    }
                }
            }
        }
    }
    
    func favoriteExists(cityLocation: CityLocation, completion: @escaping (Bool) -> Void) {
        let context = self.context
        
        DispatchQueue.global(qos: .utility).async {
            context.perform {
                let exists = self.favoriteExistsInContext(cityLocation: cityLocation, context: context)
                DispatchQueue.main.async {
                    completion(exists)
                }
            }
        }
    }
    
    private func favoriteExistsInContext(cityLocation: CityLocation, context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<FavoriteCity> = FavoriteCity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND country == %@",
                                        cityLocation.name, cityLocation.country)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}

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
