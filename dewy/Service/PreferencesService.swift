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
    
    func updatePreferences(id: Int64, userId: UUID, minAge: Int, maxAge: Int, preferredGenders: [Gender.GenderType], location: CLLocationCoordinate2D, selectedStyles: Set<Style>, allStylesPreferred: Bool) async throws {
        let preferences = UpdatePreferencesParams(
            preferencesId: id,
            userId: userId,
            minAge: minAge,
            maxAge: maxAge,
            preferredGenders: preferredGenders,
            location: location,
            selectedStyles: selectedStyles,
            allStylesPreferred: allStylesPreferred
        )
        
        try await supabase
            .rpc("update_preferences", params: preferences)
            .execute()
    }
}
