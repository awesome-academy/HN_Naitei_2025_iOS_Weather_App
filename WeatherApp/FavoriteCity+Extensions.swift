//
//  CoreDataService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation
import CoreData

class CoreDataService {
    
    func fetchAllFavorites(in context: NSManagedObjectContext) -> [FavoriteCity] {
        let request: NSFetchRequest<FavoriteCity> = FavoriteCity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteCity.dateAdded, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            debugPrint("Error fetching favorites: \(error)")
            return []
        }
    }
    
    func delete(_ favorite: FavoriteCity, in context: NSManagedObjectContext) {
        context.delete(favorite)
    }
    
    func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
