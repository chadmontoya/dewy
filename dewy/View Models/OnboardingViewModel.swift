import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var birthday: Date
    @Published var location: Location = Location(latitude: 0, longitude: 0)
    @Published var gender: Gender
    @Published var isLoading: Bool = false
    @Published var isComplete: Bool = false

    init(birthday: Date = Date(), gender: Gender = Gender(type: .male), location: Location = Location(latitude: 0, longitude: 0)) {
        self.birthday = birthday
        self.gender = gender
        self.location = location
    }
    
    @MainActor
    func saveProfile(userId: UUID) async throws {
        isLoading = true
        
        let profile = Profile(
            userId: userId,
            birthday: self.removeTimeStamp(fromDate: birthday),
            gender: gender.type.rawValue,
            location: location.postgisPointString)
        
        try await supabase
            .from("Profiles")
            .insert(profile)
            .execute()
        
        isComplete = true
        isLoading = false
    }
    
    private func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            print("couldn't remove timestamp from date")
            return fromDate
        }
        return date
    }
}

struct Restaurant: Codable {
    let name: String
    let location: String
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
    
    var postgisPointString: String {
        return "POINT(\(longitude) \(latitude))"
    }
}

struct Gender: Codable, Equatable {
    enum GenderType: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case nonBinary = "Non-Binary"
    }
    
    var type: GenderType
    
    init(type: GenderType) {
        self.type = type
    }
}

struct Country: Codable {
    let id: Int
    let name: String
}
