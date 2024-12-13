import SwiftUI
import MapKit

class OnboardingViewModel: ObservableObject {
    @Published var birthday: Date
    @Published var location: CLLocationCoordinate2D?
    @Published var gender: Gender
    @Published var isLoading: Bool = false
    @Published var isComplete: Bool = false
    
    init(birthday: Date = Date(), gender: Gender = Gender(type: .male)) {
        self.birthday = birthday
        self.gender = gender
        self.location = nil
    }
    
    @MainActor
    func saveProfile(userId: UUID) async throws {
        isLoading = true
        
        let profile: Profile = Profile(
            userId: userId,
            birthday: birthday,
            gender: gender.type.rawValue,
            location: location
        )
        
        try await supabase
            .from("Profiles")
            .insert(profile)
            .execute()
        
        isComplete = true
        isLoading = false
    }
}
