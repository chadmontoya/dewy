import SwiftUI

struct UserLocationView: View {
    
    @State var locationSearchVM = LocationSearchViewModel()
    
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    var body: some View {
        VStack {
            Text("choose your location")
                .padding()
                .font(.title)
                .bold()
                .foregroundStyle(Color.coffee)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            MapView(location: $onboardingVM.location)
            
            NavigationLink {
                GenderView()
                    .environmentObject(onboardingVM)
                    .toolbarRole(.editor)
            } label: {
                Text("Next")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(Color.coffee)
            }
            .cornerRadius(10)
            .padding()
            
            Spacer()
        }
        .background(Color.cream.ignoresSafeArea())
    }
}
