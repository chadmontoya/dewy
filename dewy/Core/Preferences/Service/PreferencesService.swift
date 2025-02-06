import Foundation
import CoreLocation

struct PreferencesService {
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
    
    func fetchLocation(userId: UUID) async throws -> CLLocationCoordinate2D {
        let location: LocationPreference = try await supabase
            .rpc("get_location_preferences")
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
