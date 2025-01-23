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
    
    func fetchLocation(userId: UUID) async throws -> CLLocationCoordinate2D {
        let location: LocationPreference = try await supabase
            .rpc("get_location_preferences")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        
        return CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
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
