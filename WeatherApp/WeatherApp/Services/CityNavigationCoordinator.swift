//
//  CityNavigationCoordinator.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import UIKit

class CityNavigationCoordinator {
    static let shared = CityNavigationCoordinator()
    
    private init() {}
    
    func navigateToHomeWith(cityLocation: CityLocation, from viewController: UIViewController) {
        guard let tabBarController = viewController.tabBarController else { return }
        
        if let homeNavController = tabBarController.viewControllers?.first as? UINavigationController,
           let homeViewController = homeNavController.viewControllers.first as? HomeViewController {
            
            homeViewController.selectedCityLocation = cityLocation
            homeViewController.selectedWeatherData = nil
            
            tabBarController.selectedIndex = 0

            homeViewController.updateDataForSelectedCity()
        }
    }
    
    func navigateToHomeWith(weatherData: WeatherDisplayData, from viewController: UIViewController) {
        guard let tabBarController = viewController.tabBarController else { return }
        
        if let homeNavController = tabBarController.viewControllers?.first as? UINavigationController,
           let homeViewController = homeNavController.viewControllers.first as? HomeViewController {
            
            homeViewController.selectedWeatherData = weatherData
            homeViewController.selectedCityLocation = nil
            
            tabBarController.selectedIndex = 0

            homeViewController.updateDataForSelectedWeather()
        }
    }
}
