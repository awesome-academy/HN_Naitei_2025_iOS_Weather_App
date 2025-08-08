//
//  DataManager.swift
//  WeatherApp
//
//  Created by Phan Quyen on 08/08/2025.
//

import CoreData
import Foundation
import UIKit

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    private var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate không tìm thấy")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    private var backgroundContext: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate không tìm thấy")
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
                
                let favorite = FavoriteCity.create(from: cityLocation, in: bgContext)
                
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
                do {
                    let favorites = FavoriteCity.fetchAll(in: context)
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
                print("Lỗi lưu context: \(error)")
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
            return "Thành phố đã có trong danh sách yêu thích"
        case .notFound:
            return "Không tìm thấy thành phố"
        case .saveFailed(let error):
            return "Lỗi lưu dữ liệu: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Lỗi xóa dữ liệu: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Lỗi tải dữ liệu: \(error.localizedDescription)"
        case .contextNotAvailable:
            return "Không thể truy cập dữ liệu"
        }
    }
}
