import Foundation
import CoreLocation

struct Profile: Codable, Identifiable {
    var id: Int64?
    var userId: UUID
    var birthday: Date?
    var gender: String?
    var location: CLLocationCoordinate2D?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case birthday
        case gender
        case location
    }
    
    init(userId: UUID = UUID(), birthday: Date? = nil, gender: String? = nil, location: CLLocationCoordinate2D? = nil) {
        self.id = nil
        self.userId = userId
        self.birthday = birthday
        self.gender = gender
        self.location = location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int64.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        
        if let birthdayString = try container.decodeIfPresent(String.self, forKey: .birthday) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            birthday = formatter.date(from: birthdayString)
        } else {
            birthday = nil
        }
        
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        
        if let geoString = try container.decodeIfPresent(String.self, forKey: .location) {
            let components = geoString
                .trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                .split(separator: " ")
                .map { Double($0.trimmingCharacters(in: .whitespaces)) }
            if let latitude = components.last, let longitude = components.first, components.count == 2 {
                location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            } else {
                location = nil
            }
        } else {
            location = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        
        if let birthday = birthday {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            try container.encode(formatter.string(from: birthday), forKey: .birthday)
        } else {
            try container.encodeNil(forKey: .birthday)
        }
        
        try container.encode(gender, forKey: .gender)
        
        if let location = location {
            let geoString = "POINT(\(location.longitude) \(location.latitude))"
            try container.encode(geoString, forKey: .location)
        } else {
            try container.encodeNil(forKey: .location)
        }
    }    
}

