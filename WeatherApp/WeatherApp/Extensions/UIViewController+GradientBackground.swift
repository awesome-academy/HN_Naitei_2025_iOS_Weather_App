//
//  UIViewController+GradientBackground.swift
//  WeatherApp
//
//  Created by Phan Quyen on 19/08/2025.
//

import UIKit

extension UIViewController {
    
    func addGradientBackground() {
        let gradientBackground = GradientBackgroundView()
        gradientBackground.frame = view.bounds
        view.insertSubview(gradientBackground, at: 0)
        
        gradientBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientBackground.topAnchor.constraint(equalTo: view.topAnchor),
            gradientBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
