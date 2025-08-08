//
//  FavoriteCity+Extensions.swift
//  WeatherApp
//
//  Created by Phan Quyen on 07/08/2025.
//

import Foundation
import CoreData
import CoreLocation

extension FavoriteCity {
    
    var displayName: String {
        if let state = state, !state.isEmpty {
            return "\(name ?? ""), \(state), \(country ?? "")"
        } else {
            return "\(name ?? ""), \(country ?? "")"
        }
    }
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var coordinatesString: String {
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
    
    func toCityLocation() -> CityLocation {
        return CityLocation(
            name: name ?? "",
            country: country ?? "",
            state: state,
            latitude: latitude,
            longitude: longitude
        )
    }
    
    static func create(from cityLocation: CityLocation, in context: NSManagedObjectContext) -> FavoriteCity {
        let favorite = FavoriteCity(context: context)
        favorite.name = cityLocation.name
        favorite.country = cityLocation.country
        favorite.state = cityLocation.state
        favorite.latitude = cityLocation.coordinates.latitude
        favorite.longitude = cityLocation.coordinates.longitude
        favorite.dateAdded = Date()
        return favorite
    }
    
    static func fetchAll(in context: NSManagedObjectContext) -> [FavoriteCity] {
        let request: NSFetchRequest<FavoriteCity> = FavoriteCity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteCity.dateAdded, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            debugPrint("Error fetching favorites: \(error)")
            return []
        }
    }
    
    static func delete(_ favorite: FavoriteCity, in context: NSManagedObjectContext) {
        context.delete(favorite)
    }
}
