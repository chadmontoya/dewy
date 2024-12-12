import SwiftUI
import MapKit

struct LocationView: View {
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var currentCity: String = ""
    @State private var searchCity: String = ""
    @State private var isUserInteracting = false
    
    @FocusState private var isSearchFocused: Bool
    
    @State var locationSearchVM = LocationSearchViewModel()
    
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    var body: some View {
        VStack {
            if !isSearchFocused {
                Text("choose your location")
                    .padding()
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.coffee)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                mapDisplay
            }
            VStack {
                locationSearchBar
                    .padding(.bottom)
                
                if !isSearchFocused {
                    NavigationLink {
                        GenderView()
                            .environmentObject(onboardingVM)
                            .environmentObject(authController)
                            .toolbarRole(.editor)
                    } label: {
                        Text("Next")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .background(Color.coffee)
                    }
                    .cornerRadius(10)
                }
                
                if !locationSearchVM.results.isEmpty && isSearchFocused {
                    locationResults
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cream)
        .onTapGesture {
            withAnimation {
                isSearchFocused = false
            }
            hideKeyboard()
        }
    }
    
    private var mapDisplay: some View {
        ZStack {
            Map(position: $cameraPosition)
                .onAppear {
                    let myLocation = CLLocationCoordinate2D(latitude: 33.975575, longitude: -117.849784)
                    let myLocationSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    let myLocationRegion = MKCoordinateRegion(center: myLocation, span: myLocationSpan)
                    cameraPosition = .region(myLocationRegion)
                    getCityName(from: myLocation)
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleRegion = context.region
                    getCityName(from: context.region.center)
                    
                    if isUserInteracting {
                        locationSearchVM.query = ""
                    }
                    
                    onboardingVM.location = context.region.center
                }
                .toolbarBackgroundVisibility(.hidden)
                .colorScheme(.light)
            
            
            Text(currentCity)
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
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
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
                                let newRegion = MKCoordinateRegion(
                                    center: newCoordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                                )
                                cameraPosition = .region(newRegion)
                                getCityName(from: newCoordinate)
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
            .background(Color.cream)
            .cornerRadius(10)
        }
    }
    
    private func getCityName(from location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("geocoding error: \(error)")
                return
            }
            
            if let city = placemarks?.first?.locality {
                currentCity = city
            }
            else {
                currentCity = "Unknown Location"
            }
        }
    }
}
