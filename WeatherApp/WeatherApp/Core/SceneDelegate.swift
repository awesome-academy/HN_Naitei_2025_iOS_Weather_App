//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        setupRootViewController()
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    private func setupRootViewController() {
        let tabBarController = createTabBarController()
        window?.rootViewController = tabBarController
    }
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let homeVC = createHomeViewController()
        let weatherVC = createWeatherViewController()
        let favoritesVC = createFavoritesViewController()
        let settingsVC = createSettingsViewController()
        
        tabBarController.viewControllers = [homeVC, weatherVC, favoritesVC, settingsVC]
        
        setupTabBarAppearance(tabBarController)
        
        return tabBarController
    }
    
    private func createHomeViewController() -> UINavigationController {
        let homeVC = HomeViewController()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        return navController
    }
    
    private func createWeatherViewController() -> UINavigationController {
        let weatherVC = WeatherViewController()
        let navController = UINavigationController(rootViewController: weatherVC)
        navController.tabBarItem = UITabBarItem(
            title: "Weather",
            image: UIImage(systemName: "cloud.sun"),
            selectedImage: UIImage(systemName: "cloud.sun.fill")
        )
        return navController
    }
    
    private func createFavoritesViewController() -> UINavigationController {
        let favoritesVC = FavoritesViewController()
        let navController = UINavigationController(rootViewController: favoritesVC)
        navController.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        return navController
    }
    
    private func createSettingsViewController() -> UINavigationController {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        settingsVC.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear.fill")
        )
        return navController
    }
    
    private func setupTabBarAppearance(_ tabBarController: UITabBarController) {
        let tabBar = tabBarController.tabBar
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.backgroundColor = .systemBackground
    }
}
