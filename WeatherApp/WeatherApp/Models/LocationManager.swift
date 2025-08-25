//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Phan Quyen on 22/08/2025.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation)
    func locationManager(_ manager: LocationManager, didFailWithError error: LocationError)
    func locationManager(_ manager: LocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
}

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    weak var delegate: LocationManagerDelegate?
    
    private let coreLocationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var isRequestingLocation = false
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        coreLocationManager.distanceFilter = 100
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        return coreLocationManager.authorizationStatus
    }
    
    var hasLocationPermission: Bool {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            coreLocationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.locationManager(self, didFailWithError: .permissionDenied)
        case .authorizedWhenInUse, .authorizedAlways:
            requestCurrentLocation()
        @unknown default:
            delegate?.locationManager(self, didFailWithError: .serviceUnavailable)
        }
    }
    
    func requestCurrentLocation() {
        guard hasLocationPermission else {
            requestLocationPermission()
            return
        }
        
        guard !isRequestingLocation else { return }
        guard CLLocationManager.locationServicesEnabled() else {
            delegate?.locationManager(self, didFailWithError: .serviceUnavailable)
            return
        }
        
        if let cachedLocation = currentLocation,
           cachedLocation.timestamp.timeIntervalSinceNow > -300 {
            delegate?.locationManager(self, didUpdateLocation: cachedLocation)
            return
        }
        
        isRequestingLocation = true
        coreLocationManager.requestLocation()
    }
    
    func getCurrentLocation() -> CLLocation? {
        return currentLocation
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let locationAge = abs(location.timestamp.timeIntervalSinceNow)
        guard locationAge < 30.0 else { return }
        guard location.horizontalAccuracy < 1000 else { return }
        
        currentLocation = location
        isRequestingLocation = false
        
        delegate?.locationManager(self, didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequestingLocation = false
        
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                delegate?.locationManager(self, didFailWithError: .locationNotFound)
            case .denied:
                delegate?.locationManager(self, didFailWithError: .permissionDenied)
            case .network:
                delegate?.locationManager(self, didFailWithError: .networkError)
            default:
                delegate?.locationManager(self, didFailWithError: .serviceUnavailable)
            }
        } else {
            delegate?.locationManager(self, didFailWithError: .serviceUnavailable)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManager(self, didChangeAuthorizationStatus: status)
    }
}
