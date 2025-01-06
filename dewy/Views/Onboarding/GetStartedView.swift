import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var authController: AuthController
    
    @State private var onboardingComplete = false

    var body: some View {
        VStack {
            Text("thank you")
                .padding()
                .font(.title)
                .bold()
                .foregroundStyle(Color.coffee)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button {
                Task {
                    try await onboardingVM.saveProfile(userId: authController.currentUserId)
                    onboardingComplete = true
                    authController.requireOnboarding = false
                }
            } label: {
                Text("Get Started")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(Color.coffee)
            }
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cream)
    }
}
