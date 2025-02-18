import Foundation
import CoreLocation

struct OnboardingService {
    func addPreferences(userId: UUID, minAge: Int, maxAge: Int, preferredGenders: [Gender.GenderType], location: CLLocationCoordinate2D?) async throws -> Preferences {
        var preferences: Preferences = try await supabase
            .from("Preferences")
            .insert(
                Preferences(
                    userId: userId,
                    minAge: minAge,
                    maxAge: maxAge,
                    preferredGenders: preferredGenders,
                    location: location
                )
            )
            .select()
            .single()
            .execute()
            .value
        
        preferences.location = location
        preferences.selectedStyleIds = []
        
        return preferences
    }
    
    func addProfile(userId: UUID, birthday: Date, gender: Gender, location: CLLocationCoordinate2D?) async throws {
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
        
    }
}
