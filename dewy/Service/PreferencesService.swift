import Foundation
import CoreLocation

struct PreferencesService {
    func fetchPreferences(userId: UUID) async throws -> Preferences {
        let preferences: Preferences = try await supabase
            .rpc("get_preferences")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        return preferences
    }
    
    func savePreferences(userId: UUID, minAge: Int, maxAge: Int, preferredGenders: [Gender.GenderType], location: CLLocationCoordinate2D?) async throws {
        let preferences: Preferences = Preferences(
            userId: userId,
            minAge: minAge,
            maxAge: maxAge,
            preferredGenders: preferredGenders,
            location: location
        )
        
        try await supabase
            .from("Preferences")
            .insert(preferences)
            .execute()
    }
}
