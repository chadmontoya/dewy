import SwiftUI

struct OnboardingView: View {
    @StateObject var onboardingVM: OnboardingViewModel = OnboardingViewModel()

    var body: some View {
        BirthdayView()
            .environmentObject(onboardingVM)
    }
}
