import Foundation
import CoreLocation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var birthday: Date = Date()
    @Published var location: CLLocationCoordinate2D? = nil
    @Published var gender: Gender = Gender(type: .male)
    @Published var isLoading: Bool = false
    @Published var isComplete: Bool = false
    
    private let profileService: ProfileService
    private let preferencesService: PreferencesService
    
    init(profileService: ProfileService, preferencesService: PreferencesService) {
        self.profileService = profileService
        self.preferencesService = preferencesService
    }
    
    func completeOnboarding(userId: UUID) async throws {
        isLoading = true
        
        try await profileService.saveProfile(
            userId: userId,
            birthday: birthday,
            gender: gender,
            location: location
        )
        
        isComplete = true
        isLoading = false
    }
}
