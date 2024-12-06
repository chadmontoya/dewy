import SwiftUI

class OnboardingData: ObservableObject {
    @Published var birthday: Date
    @Published var location: Location = Location(latitude: 0, longitude: 0)
    @Published var gender: Gender
    
    init(birthday: Date = Date(), gender: Gender = Gender(type: .male), location: Location = Location(latitude: 0, longitude: 0)) {
        self.birthday = birthday
        self.gender = gender
        self.location = location
    }
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
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
