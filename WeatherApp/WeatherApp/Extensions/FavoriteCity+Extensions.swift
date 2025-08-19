//
//  CoreDataService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation
import CoreData
import CoreLocation

extension FavoriteCity {
    
    convenience init(from cityLocation: CityLocation, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = cityLocation.name
        self.country = cityLocation.country
        self.state = cityLocation.state
        self.latitude = cityLocation.coordinates.latitude
        self.longitude = cityLocation.coordinates.longitude
        self.dateAdded = Date()
    }
    
    var displayName: String {
        let components = [name, state, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var coordinatesString: String {
        return "\(latitude.coordinateFormat), \(longitude.coordinateFormat)"
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
}
