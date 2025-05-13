import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var status: CLAuthorizationStatus?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocationPermission() {
        print("📍 Calling requestWhenInUseAuthorization")
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        self.status = newStatus

        switch newStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission granted")
            locationManager.requestLocation()
        case .denied:
            print("❌ Location access denied by user")
        case .restricted:
            print("⚠️ Location access is restricted")
        case .notDetermined:
            print("🔄 Location permission not yet determined")
        @unknown default:
            print("❓ Unknown authorization status")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            location = loc
            print("📍 Location updated: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("🚫 Location error: \(error.localizedDescription)")
    }

    func isAuthorized() -> Bool {
        let currentStatus = locationManager.authorizationStatus
        return currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways
    }
}
