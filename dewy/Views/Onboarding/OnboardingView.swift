import SwiftUI

struct OnboardingView: View {
    @StateObject private var onboardingData: OnboardingData = OnboardingData()
    
    var body: some View {
        NavigationStack {
            BirthdayView()
                .environmentObject(onboardingData)
        }
        .tint(Color.coffee)
    }
}
