import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authController: AuthController
    @StateObject var onboardingVM: OnboardingViewModel = OnboardingViewModel()

    var body: some View {
        BirthdayView()
            .environmentObject(onboardingVM)
            .environmentObject(authController)
    }
}
