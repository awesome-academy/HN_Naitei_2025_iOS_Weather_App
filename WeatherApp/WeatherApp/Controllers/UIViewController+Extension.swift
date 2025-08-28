//
//  UIViewController+Extension.swift
//  WeatherApp
//
//  Created by Phan Quyen on 18/08/2025.
//

import UIKit

extension UIViewController {
    
    func setupForecastBackground() {
        let forecastBg = ForecastGradientView()
        
        view.insertSubview(forecastBg, at: 0)
        
        forecastBg.frame = CGRect(
            x: 0,
            y: view.frame.height * 0.65,
            width: view.frame.width,
            height: view.frame.height * 0.35
        )

        view.subviews.forEach { subview in
            if subview.frame.minY > 500 {
                subview.backgroundColor = .clear
                subview.subviews.forEach { innerView in
                    innerView.backgroundColor = .clear
                }
            }
        }
    }
    
    func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(
            title: "OK",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
        }
    }
    
    func showDetailAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
