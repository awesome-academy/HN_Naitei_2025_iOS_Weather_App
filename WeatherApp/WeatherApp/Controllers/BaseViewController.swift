//
//  BaseViewController.swift
//  WeatherApp
//
//  Created by Phan Quyen on 06/08/2025.
//

import UIKit

class BaseViewController: UIViewController {
    
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func showLoading() {
        guard !isLoading else { return }
        isLoading = true
        
        DispatchQueue.main.async {
            if self.view.viewWithTag(1000) != nil {
                return
            }
            
            let loadingView = UIView()
            loadingView.tag = 1000
            loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.color = .white
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.startAnimating()
            
            loadingView.addSubview(activityIndicator)
            self.view.addSubview(loadingView)
            
            NSLayoutConstraint.activate([
                loadingView.topAnchor.constraint(equalTo: self.view.topAnchor),
                loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                
                activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
            ])
            
            self.view.isUserInteractionEnabled = false
        }
    }
    
    func hideLoading() {
        isLoading = false
        
        DispatchQueue.main.async {
            if let loadingView = self.view.viewWithTag(1000) {
                loadingView.removeFromSuperview()
            }
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func showError(title: String = "Error", message: String, onCompleted: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                onCompleted?()
            })
            self.present(alert, animated: true)
        }
    }
    
    func showSuccess(title: String = "Success", message: String, onCompleted: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                onCompleted?()
            })
            self.present(alert, animated: true)
        }
    }
}
