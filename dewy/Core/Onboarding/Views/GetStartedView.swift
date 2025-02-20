import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject var authController: AuthController
    
    @ObservedObject var preferencesVM: PreferencesViewModel
    @ObservedObject var onboardingVM: OnboardingViewModel
    
    @State private var onboardingComplete = false
    
    var body: some View {
        VStack {
            Text("thank you")
                .padding()
                .font(.title)
                .bold()
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button {
                Task {
                    if let userId = authController.session?.user.id {
                        let preferences: Preferences = try await onboardingVM.completeOnboarding(userId: userId)
                        if let preferencesId = preferences.id {
                            preferencesVM.preferencesId = preferencesId
                            preferencesVM.setPreferences(from: preferences)
                        }
                        
                        onboardingComplete = true
                        authController.requireOnboarding = false
                    }
                }
            } label: {
                Text("Get Started")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(.black)
            }
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cream)
    }
}
