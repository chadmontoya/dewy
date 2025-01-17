import SwiftUI

struct OnboardingView: View {
    @StateObject var onboardingVM: OnboardingViewModel = OnboardingViewModel(
        profileService: ProfileService(),
        preferencesService: PreferencesService()
    )
    
    var body: some View {
        VStack {
            NavigationStack {
                BirthdayView()
                    .environmentObject(onboardingVM)
            }
        }
    }
}
