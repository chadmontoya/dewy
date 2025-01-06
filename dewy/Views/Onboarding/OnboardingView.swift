import SwiftUI

struct OnboardingView: View {
    @StateObject var onboardingVM: OnboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        VStack {
            NavigationStack {
                BirthdayView()
                    .environmentObject(onboardingVM)
            }
        }
    }
}
