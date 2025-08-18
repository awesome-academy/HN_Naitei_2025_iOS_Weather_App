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
        
        let viewControllers = TabBarType.allCases.map { tabType in
            createViewController(for: tabType)
        }
        
        tabBarController.viewControllers = viewControllers
        setupTabBarAppearance(tabBarController)
        
        return tabBarController
    }
    
    private func createViewController(for tabType: TabBarType) -> UINavigationController {
        let viewController: UIViewController
        
        switch tabType {
        case .home:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        case .weather:
            viewController = WeatherViewController()
        case .favorites:
            viewController = FavoritesViewController()
        case .settings:
            viewController = SettingsViewController()
        }
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem = UITabBarItem(
            title: tabType.title,
            image: tabType.image,
            selectedImage: tabType.selectedImage
        )
        
        return navController
    }
    
    private func setupTabBarAppearance(_ tabBarController: UITabBarController) {
        let tabBar = tabBarController.tabBar
        
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = UIColor.clear
        tabBar.isTranslucent = true

        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .lightGray
    }
}
