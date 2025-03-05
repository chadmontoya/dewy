import CoreLocation

class LocationManager: NSObject, ObservableObject {
    @Published private(set) var manager = CLLocationManager()
    @Published private(set) var currentCity: String = ""
    @Published var locationStatus: LocationStatus = .unknown
    @Published var userLocation: CLLocation = CLLocation(latitude: 34.0549, longitude: -118.2426)

    enum LocationStatus {
        case unknown
        case valid(city: String)
        case error(String)
    }
    
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
    
    func updateLocationInfo(from location: CLLocation) {
        Task {
            do {
                let geocoder = CLGeocoder()
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                
                await MainActor.run {
                    if let city = placemarks.first?.locality {
                        self.currentCity = city
                        self.locationStatus = .valid(city: city)
                    } else {
                        self.currentCity = "Unknown Location"
                        self.locationStatus = .unknown
                    }
                }
            } catch {
                await MainActor.run {
                    self.currentCity = "Unknown Location"
                    self.locationStatus = .error(error.localizedDescription)
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("not determined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
        updateLocationInfo(from: location)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed with error: \(error.localizedDescription)")
    }
}
