//
//  LocationService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 21/08/2025.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func locationService(_ service: LocationService, didUpdateLocation location: CLLocation)
    func locationService(_ service: LocationService, didFailWithError error: LocationError)
    func locationServiceDidChangePermission(_ service: LocationService, status: CLAuthorizationStatus)
}

class LocationService: NSObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    weak var delegate: LocationServiceDelegate?
    
    private var isRequestingLocation = false
    private var currentLocation: CLLocation?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
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
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.locationService(self, didFailWithError: .permissionDenied)
        case .authorizedWhenInUse, .authorizedAlways:
            requestCurrentLocation()
        @unknown default:
            delegate?.locationService(self, didFailWithError: .serviceUnavailable)
        }
    }
    
    func requestCurrentLocation() {
        guard hasLocationPermission else {
            requestLocationPermission()
            return
        }
        
        guard !isRequestingLocation else { return }
        
        if CLLocationManager.locationServicesEnabled() {
            isRequestingLocation = true
            
            if let cachedLocation = currentLocation,
               cachedLocation.timestamp.timeIntervalSinceNow > -300 {
                delegate?.locationService(self, didUpdateLocation: cachedLocation)
                isRequestingLocation = false
                return
            }
            
            locationManager.requestLocation()
        } else {
            delegate?.locationService(self, didFailWithError: .serviceUnavailable)
        }
    }
    
    func startLocationUpdates() {
        guard hasLocationPermission else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isRequestingLocation = false
    }
    
    func getCurrentLocation() -> CLLocation? {
        return currentLocation
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let locationAge = abs(location.timestamp.timeIntervalSinceNow)
        guard locationAge < 30.0 else {
            return
        }
        
        guard location.horizontalAccuracy < 1000 else {
            return
        }
        
        currentLocation = location
        isRequestingLocation = false
        
        delegate?.locationService(self, didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequestingLocation = false
        
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                delegate?.locationService(self, didFailWithError: .locationNotFound)
            case .denied:
                delegate?.locationService(self, didFailWithError: .permissionDenied)
            case .network:
                delegate?.locationService(self, didFailWithError: .networkError)
            default:
                delegate?.locationService(self, didFailWithError: .serviceUnavailable)
            }
        } else {
            delegate?.locationService(self, didFailWithError: .serviceUnavailable)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization changed: \(status.rawValue)")
        delegate?.locationServiceDidChangePermission(self, status: status)
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        case .denied, .restricted:
            delegate?.locationService(self, didFailWithError: .permissionDenied)
        default:
            break
        }
    }
}
