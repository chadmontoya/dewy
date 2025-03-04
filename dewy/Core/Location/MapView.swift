import SwiftUI
import MapKit

struct MapView: View {
    @Binding var location: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var searchCity: String = ""
    @State private var isMapInitialized: Bool = false
    @FocusState var isSearchFocused: Bool
    @State var locationSearchVM = LocationSearchViewModel()
    @StateObject var locationManager = LocationManager.shared
    
    var body: some View {
        VStack {
            if !isSearchFocused {
                mapDisplay
            }
            VStack {
                locationSearchBar
                    .padding(.bottom)
                
                if !locationSearchVM.results.isEmpty && isSearchFocused {
                    locationResults
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isSearchFocused = false
            }
            hideKeyboard()
        }
        .onAppear {
            if location == nil {
                locationManager.requestLocation()
                location = locationManager.userLocation.coordinate
            }
        }
        
        Spacer()
    }
    
    private var mapDisplay: some View {
        ZStack {
            Map(position: $cameraPosition)
                .onAppear {
                    if !isMapInitialized,
                       let mapCoordinate = location {
                        let mapLocation = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
                        let mapLocationRegion = MKCoordinateRegion(
                            center: mapCoordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                        cameraPosition = .region(mapLocationRegion)
                        locationManager.updateLocationInfo(from: mapLocation)
                        isMapInitialized = true
                    }
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    guard isMapInitialized else { return }
                    let mapCoordinate = context.region.center
                    let mapLocation = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
                    let mapLocationRegion = MKCoordinateRegion(
                        center: mapCoordinate,
                        span: context.region.span
                    )
                    cameraPosition = .region(mapLocationRegion)
                    location = mapCoordinate
                    locationManager.updateLocationInfo(from: mapLocation)
                }
                .onChange(of: locationManager.userLocation) {
                    location = locationManager.userLocation.coordinate
                    if let mapCoordinate = location {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: mapCoordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            )
                        )
                    }
                }
                .toolbarBackgroundVisibility(.hidden)
                .colorScheme(.light)
            
            Text(locationManager.currentCity)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(8)
                .shadow(radius: 2)
                .colorScheme(.light)
        }
        .frame(height: 400)
    }
    
    private var locationSearchBar: some View {
        TextField("", text: $locationSearchVM.query, prompt: Text("Search...").foregroundStyle(.gray))
            .focused($isSearchFocused)
            .foregroundStyle(.black)
            .autocorrectionDisabled()
            .padding()
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.8), lineWidth: 1)
                            )
                    )
            )
            .overlay(
                HStack {
                    Spacer()
                    if !locationSearchVM.query.isEmpty {
                        Button(action: {
                            locationSearchVM.query = ""
                            isSearchFocused = false
                            hideKeyboard()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                }
            )
    }
    
    private var locationResults: some View {
        ScrollView {
            VStack {
                ForEach(locationSearchVM.results) { result in
                    Button(action: {
                        locationSearchVM.query = result.title
                        isSearchFocused = false
                        
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(result.title) { placemarks, error in
                            if let error = error {
                                print("geocoding error: \(error)")
                                return
                            }
                            
                            if let location = placemarks?.first?.location {
                                let newCoordinate = location.coordinate
                                locationManager.updateLocationInfo(from: location)
                                let newRegion = MKCoordinateRegion(
                                    center: newCoordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                                )
                                cameraPosition = .region(newRegion)
                            }
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.title)
                                    .foregroundStyle(.black)
                                Text(result.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    Divider()
                }
            }
            .cornerRadius(10)
        }
    }
}
