import Foundation
import CoreLocation

struct ProfileService {
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
