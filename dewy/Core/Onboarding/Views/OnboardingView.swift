import SwiftUI

struct OnboardingView: View {
    @ObservedObject var preferencesVM: PreferencesViewModel
    
    @StateObject var onboardingVM: OnboardingViewModel = OnboardingViewModel(
        preferencesService: PreferencesService(),
        profileService: ProfileService(),
        collectionService: CollectionService()
    )
    
    var body: some View {
        VStack {
            NavigationStack {
                BirthdayView(
                    preferencesVM: preferencesVM,
                    onboardingVM: onboardingVM
                )
            }
        }
    }
}
