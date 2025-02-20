import SwiftUI

struct UserLocationView: View {
    @EnvironmentObject var preferencesVM: PreferencesViewModel
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    @State var locationSearchVM = LocationSearchViewModel()
    
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
                GenderView()
                    .environmentObject(onboardingVM)
                    .environmentObject(preferencesVM)
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
        .background(Color.cream.ignoresSafeArea())
    }
}
