//
//  LocationService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 08/08/2025.
//

import CoreLocation
import Foundation

class LocationService: NSObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((Result<CLLocationCoordinate2D, LocationError>) -> Void)?
    
    override private init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, LocationError>) -> Void) {
        locationCompletion = completion
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            completion(.failure(.permissionDenied))
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdate()
        @unknown default:
            completion(.failure(.permissionDenied))
        }
    }
    
    private func startLocationUpdate() {
        guard CLLocationManager.locationServicesEnabled() else {
            locationCompletion?(.failure(.serviceUnavailable))
            return
        }
        locationManager.requestLocation()
    }
    
    func hasLocationPermission() -> Bool {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationCompletion?(.failure(.locationNotFound))
            return
        }
        
        let coordinate = location.coordinate
        locationCompletion?(.success(coordinate))
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationCompletion?(.failure(.permissionDenied))
            case .network:
                locationCompletion?(.failure(.networkError))
            case .locationUnknown:
                locationCompletion?(.failure(.locationNotFound))
            default:
                locationCompletion?(.failure(.timeout))
            }
        } else {
            locationCompletion?(.failure(.networkError))
        }
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if locationCompletion != nil {
                startLocationUpdate()
            }
        case .denied, .restricted:
            locationCompletion?(.failure(.permissionDenied))
            locationCompletion = nil
        case .notDetermined:
            break
        @unknown default:
            locationCompletion?(.failure(.permissionDenied))
            locationCompletion = nil
        }
    }
}
