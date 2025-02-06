import Foundation
import CoreLocation

struct ProfileService {
    func saveProfile(userId: UUID, birthday: Date, gender: Gender) async throws {
        let profile: Profile = Profile(
            userId: userId,
            birthday: birthday,
            gender: gender.type.rawValue
        )
        
        try await supabase
            .from("Profiles")
            .insert(profile)
            .execute()
        
    }
}
