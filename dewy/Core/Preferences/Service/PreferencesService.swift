import Foundation
import CoreLocation

struct PreferencesService {
    
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
    
    func fetchPreferences(userId: UUID) async throws -> Preferences {
        do {
            let preferences: Preferences = try await supabase
                .rpc("get_preferences")
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value
            
            return preferences
        } catch {
            print("error fetching preferences: \(error)")
            throw error
        }
    }
    
    func fetchProfileLocation(userId: UUID) async throws -> CLLocationCoordinate2D {
        let location: LocationPreference = try await supabase
            .rpc("get_profile_location")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        
        return CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
    }
    
    
    
    func updatePreferences(id: Int64, userId: UUID, minAge: Int, maxAge: Int, preferredGenders: [Gender.GenderType], location: CLLocationCoordinate2D, selectedStyles: Set<Style>, allStylesPreferred: Bool) async {
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
        
        do {
            try await supabase
                .rpc("update_preferences", params: preferences)
                .execute()
        } catch {
            print("error updating preferences: \(error)")
        }
    }
}
