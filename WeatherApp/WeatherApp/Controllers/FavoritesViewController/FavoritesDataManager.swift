//
//  FavoritesDataManager.swift
//  WeatherApp
//
//  Created by Phan Quyen on 20/08/2025.
//

import UIKit

extension FavoritesViewController {
    
    func loadFavorites() {
        DataManager.shared.getAllFavorites { [weak self] result in
            switch result {
            case .success(let favorites):
                self?.favoritesList = favorites
                self?.favoritesTableView.reloadData()
                self?.updateEmptyState()
                
                // Load weather data for all favorites
                self?.loadWeatherDataForAllFavorites()
            case .failure(let error):
                self?.showErrorAlert(message: error.localizedDescription)
                self?.updateEmptyState()
            }
        }
    }
    
    private func loadWeatherDataForAllFavorites() {
        for (index, favorite) in favoritesList.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            loadWeatherForFavorite(favorite, at: indexPath)
        }
    }
    
    func updateEmptyState() {
        if favoritesList.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    private func showEmptyState() {
        let emptyView = createEmptyStateView()
        favoritesTableView.backgroundView = emptyView
    }
    
    private func hideEmptyState() {
        favoritesTableView.backgroundView = nil
    }
    
    private func createEmptyStateView() -> UIView {
        let containerView = UIView()
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.slash")
        imageView.tintColor = .white.withAlphaComponent(0.6)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "No Favorite Cities"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = .white.withAlphaComponent(0.8)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = "Add cities to your favorites from the Weather tab\nby tapping the heart icon"
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = .white.withAlphaComponent(0.6)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -60),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40)
        ])
        
        return containerView
    }
}
