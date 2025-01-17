import CoreLocation

extension CLLocationCoordinate2D {
    func getCityLocation(completion: @escaping (Result<String, Error>) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let placemark = placemarks?.first {
                var locationString = ""
                
                if let city = placemark.locality {
                    locationString = city
                }
                
                if let state = placemark.administrativeArea {
                    locationString += locationString.isEmpty ? state: ", \(state)"
                }
                
                if let country = placemark.country {
                    locationString += locationString.isEmpty ? country: ", \(country)"
                }
                
                completion(.success(locationString))
            }
            else {
                completion(.failure(NSError(domain: "geocoding", code: 0, userInfo: [NSLocalizedDescriptionKey: "no placemarks found."])))
            }
        }
    }
}
