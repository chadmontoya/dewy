import Foundation
import CoreLocation

struct Preferences {
    var id: Int64?
    var userId: UUID
    var minAge: Int
    var maxAge: Int
    var preferredGenders: [Gender.GenderType]
    var location: CLLocationCoordinate2D?
    var radius: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case minAge = "min_age"
        case maxAge = "max_age"
        case preferredGenders = "preferred_genders"
        case location
        case latitude = "lat"
        case longitude = "long"
        case radius
    }
    
    init(userId: UUID, minAge: Int = 18, maxAge: Int = 19, preferredGenders: [Gender.GenderType], location: CLLocationCoordinate2D? = nil) {
        self.id = nil
        self.userId = userId
        self.minAge = minAge
        self.maxAge = maxAge
        self.preferredGenders = preferredGenders
        self.location = location
        self.radius = 0
    }
    
}

extension Preferences: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int64.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        minAge = try container.decode(Int.self, forKey: .minAge)
        maxAge = try container.decode(Int.self, forKey: .maxAge)
        preferredGenders = try container.decode([String].self, forKey: .preferredGenders)
            .compactMap(Gender.GenderType.init)
        
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        else {
            location = nil
        }
        
        radius = try container.decodeIfPresent(Double.self, forKey: .radius)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(minAge, forKey: .minAge)
        try container.encode(maxAge, forKey: .maxAge)
        try container.encode(preferredGenders.map(\.rawValue), forKey: .preferredGenders)
        
        if let location = location {
            try container.encode("POINT(\(location.longitude) \(location.latitude))", forKey: .location)
        }
        else {
            try container.encodeNil(forKey: .location)
        }
    }
}
