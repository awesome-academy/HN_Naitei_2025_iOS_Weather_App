//
//  TabBarType.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

enum TabBarType: Int, CaseIterable {
    case home = 0
    case weather = 1
    case favorites = 2
    case settings = 3
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .weather: return "Weather"
        case .favorites: return "Favorites"
        case .settings: return "Settings"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .home: return UIImage(systemName: "house")
        case .weather: return UIImage(systemName: "cloud.sun")
        case .favorites: return UIImage(systemName: "heart")
        case .settings: return UIImage(systemName: "gear")
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .home: return UIImage(systemName: "house.fill")
        case .weather: return UIImage(systemName: "cloud.sun.fill")
        case .favorites: return UIImage(systemName: "heart.fill")
        case .settings: return UIImage(systemName: "gear.fill")
        }
    }
}
