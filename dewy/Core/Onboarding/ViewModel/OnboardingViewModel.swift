import Foundation
import CoreLocation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var birthday: Date = Date() {
        didSet {
            setAgeRange()
        }
    }
    @Published var location: CLLocationCoordinate2D? = nil
    @Published var gender: Gender = Gender(type: .male) {
        didSet {
            preferredGenders = [gender.type]
        }
    }
    @Published var isLoading: Bool = false
    @Published var isComplete: Bool = false
    
    private var preferredGenders: [Gender.GenderType] = [Gender(type: .male).type]
    private var minAge: Int = 18
    private var maxAge: Int = 19
    
    private let preferencesService: PreferencesService
    private let profileService: ProfileService
    private let collectionService: CollectionService
    
    init(preferencesService: PreferencesService, profileService: ProfileService, collectionService: CollectionService) {
        self.preferencesService = preferencesService
        self.profileService = profileService
        self.collectionService = collectionService
    }
    
    func completeOnboarding(userId: UUID) async throws -> Preferences {
        isLoading = true
        
        try await profileService.addProfile(
            userId: userId,
            birthday: birthday,
            gender: gender,
            location: location
        )
        
        let _: Collection = try await collectionService.createCollection(
            userId: userId, name: "default"
        )
        
        let preferences: Preferences = try await preferencesService.addPreferences(
            userId: userId,
            minAge: minAge,
            maxAge: maxAge,
            preferredGenders: preferredGenders,
            location: location
        )
        
        isLoading = false
        isComplete = true
        
        return preferences
    }
    
    private func setAgeRange() {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        if let age = ageComponents.year {
            minAge = age
            maxAge = age + 5
        }
    }
}
