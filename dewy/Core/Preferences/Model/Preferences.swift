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
    
    var allStylesPreferred: Bool
    var selectedStyleIds: [Int64]?

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
        case allStylesPreferred = "all_styles_preferred"
        case selectedStyleIds = "style_ids"
    }
    
    init(userId: UUID, minAge: Int = 18, maxAge: Int = 19, preferredGenders: [Gender.GenderType], location: CLLocationCoordinate2D? = nil) {
        self.id = nil
        self.userId = userId
        self.minAge = minAge
        self.maxAge = maxAge
        self.preferredGenders = preferredGenders
        self.location = location
        self.radius = 0
        self.allStylesPreferred = true
    }
    
    init(id: Int64, userId: UUID, minAge: Int, maxAge: Int, preferredGenders: [Gender.GenderType], location: CLLocationCoordinate2D, allStylesPreferred: Bool) {
        self.id = id
        self.userId = userId
        self.minAge = minAge
        self.maxAge = maxAge
        self.preferredGenders = preferredGenders
        self.location = location
        self.radius = 0
        self.allStylesPreferred = allStylesPreferred
    }
}

struct UpdatePreferencesParams: Encodable, Sendable {
    let p_preferences_id: Int64
    let p_user_id: UUID
    let p_min_age: Int
    let p_max_age: Int
    let p_preferred_genders: [String]
    let p_location: String
    let p_all_styles_preferred: Bool
    let p_style_ids: [Int64]
    
    init(
        preferencesId: Int64,
        userId: UUID,
        minAge: Int,
        maxAge: Int,
        preferredGenders: [Gender.GenderType],
        location: CLLocationCoordinate2D,
        selectedStyles: Set<Style>,
        allStylesPreferred: Bool
    ) {
        self.p_preferences_id = preferencesId
        self.p_user_id = userId
        self.p_min_age = minAge
        self.p_max_age = maxAge
        self.p_preferred_genders = preferredGenders.map { $0.rawValue }
        self.p_location = "POINT(\(location.longitude) \(location.latitude))"
        self.p_all_styles_preferred = allStylesPreferred
        self.p_style_ids = selectedStyles.map(\.id)
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
        allStylesPreferred = try container.decode(Bool.self, forKey: .allStylesPreferred)
        selectedStyleIds = try container.decodeIfPresent([Int64].self, forKey: .selectedStyleIds)
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
        
        try container.encode(allStylesPreferred, forKey: .allStylesPreferred)
    }
}

struct LocationPreference: Decodable {
    let lat: Double
    let long: Double
    let userId: UUID
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    enum CodingKeys: String, CodingKey {
        case lat
        case long
        case userId = "user_id"
    }
}
