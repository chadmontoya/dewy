import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var preferencesVM: PreferencesViewModel
    @StateObject var onboardingVM: OnboardingViewModel = OnboardingViewModel(preferencesService: PreferencesService(), profileService: ProfileService(), collectionsService: CollectionsService())
    
    var body: some View {
        VStack {
            NavigationStack {
                BirthdayView()
                    .environmentObject(onboardingVM)
                    .environmentObject(preferencesVM)
            }
        }
    }
}
