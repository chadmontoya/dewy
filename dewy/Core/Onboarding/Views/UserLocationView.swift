import SwiftUI

struct UserLocationView: View {
    @ObservedObject var preferencesVM: PreferencesViewModel
    @ObservedObject var onboardingVM: OnboardingViewModel
    
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
                    .background(.black)
            }
            .cornerRadius(10)
            .padding()
            
            Spacer()
        }
        .background(Color.primaryBackground.ignoresSafeArea())
    }
}
