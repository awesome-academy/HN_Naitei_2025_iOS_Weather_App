//
//  GradientBackgroundView.swift
//  WeatherApp
//
//  Created by Phan Quyen on 19/08/2025.
//

import UIKit

class GradientBackgroundView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.25, green: 0.15, blue: 0.6, alpha: 1.0).cgColor,
            UIColor(red: 0.3, green: 0.2, blue: 0.7, alpha: 1.0).cgColor,
            UIColor(red: 0.35, green: 0.25, blue: 0.8, alpha: 1.0).cgColor,
            UIColor(red: 0.4, green: 0.3, blue: 0.9, alpha: 1.0).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
