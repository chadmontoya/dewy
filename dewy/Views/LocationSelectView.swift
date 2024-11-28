import SwiftUI
import MapKit

struct LocationSelectView: View {
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var currentCity: String = ""
    
    func getCityName(from location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }
            
            if let city = placemarks?.first?.locality {
                currentCity = city
            } else {
                currentCity = "Unknown Location"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition)
                .onAppear {
                    let myLocation = CLLocationCoordinate2D(latitude: 33.975575, longitude: -117.849784)
                    let myLocationSpan = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                    let myLocationRegion = MKCoordinateRegion(center: myLocation, span: myLocationSpan)
                    cameraPosition = .region(myLocationRegion)
                    getCityName(from: myLocation)
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleRegion = context.region
                    getCityName(from: context.region.center)
                }
            
            // City name text box in center
            Text(currentCity)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(8)
                .shadow(radius: 2)
        }
    }
}

#Preview {
    LocationSelectView()
}
