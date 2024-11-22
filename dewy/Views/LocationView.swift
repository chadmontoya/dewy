import SwiftUI
import MapKit

struct LocationView: View {
    @State private var position: MapCameraPosition
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var locationName = ""
    
    private let initialCoordinate = CLLocationCoordinate2D(
        latitude: 37.7749,
        longitude: -122.4194
    )
    
    var onLocationSelect: (CLLocationCoordinate2D, String) => Void
    
    init(onLocationSelect: @escaping(CLLocationCoordinate2D, String) -> Void) {
        self.onLocationSelect = onLocationSelect
        
        _position = State(initialValue: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        ))
    }
    
    var body: some View {
        Map(position: $position) {
            
            // user's initial location marker
            Annotation("Initial", coordinate: initialCoordinate) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title)
            }
            
            // selected location marker
            if let selectedLocation = selectedLocation {
                Annotation("Selected", coordinate: selectedLocation) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .mapTap
    }
}
