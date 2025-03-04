import SwiftUI

struct UserLocationView: View {
    @ObservedObject var preferencesVM: PreferencesViewModel
    @ObservedObject var onboardingVM: OnboardingViewModel
    @StateObject var locationManager: LocationManager = .shared
    
    private var isLocationValid: Bool {
        if case .valid = locationManager.locationStatus {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack {
            Text("choose your location")
                .padding()
                .font(.title)
                .bold()
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            MapView(location: $onboardingVM.location)
            
            NavigationLink {
                GenderView(
                    preferencesVM: preferencesVM,
                    onboardingVM: onboardingVM
                )
                .toolbarRole(.editor)
            } label: {
                Text("Next")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(isLocationValid ? .black : .gray)
            }
            .disabled(!isLocationValid)
            .cornerRadius(10)
            .padding()
            
            Spacer()
        }
        .background(Color.primaryBackground.ignoresSafeArea())
    }
}
