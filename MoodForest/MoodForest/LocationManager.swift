//
//  LocationManager.swift
//  MoodForest
//
//  Created by Mariia Rybak on 08.05.2025.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var status: CLAuthorizationStatus?
    

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocationPermission() {
        print("📍 Calling requestWhenInUseAuthorization")
        locationManager.requestWhenInUseAuthorization()
    }


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.status = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            print("Location access denied or restricted.")
        case .notDetermined:
            print("Location permission not yet requested.")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        if let loc = location {
            print("Location updated: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func isAuthorized() -> Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }

}
