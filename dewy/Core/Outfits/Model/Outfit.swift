import SwiftUI
import CoreLocation

struct Outfit: Identifiable {
    var id: Int64
    var createDate: Date
    var userId: UUID?
    var imageURL: String
    var location: CLLocationCoordinate2D?
    var isPublic: Bool?
    var styleIds: [Int64]
    var locationString: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case createDate = "created_at"
        case userId = "user_id"
        case imageURL = "image_url"
        case location
        case latitude = "lat"
        case longitude = "long"
        case isPublic = "public"
        case styleIds = "style_ids"
        case locationString = "location_string"
    }
    
    init(userId: UUID, imageURL: String, location: CLLocationCoordinate2D? = nil,
         isPublic: Bool? = nil, styleIds: [Int64] = [], locationString: String = "") {
        self.id = 0
        self.createDate = Date()
        self.userId = userId
        self.imageURL = imageURL
        self.location = location
        self.isPublic = isPublic
        self.styleIds = styleIds
        self.locationString = locationString
    }
}

struct CreateOutfitParams: Encodable, Sendable {
    let p_user_id: UUID
    let p_image_url: String
    let p_location: String
    let p_location_string: String
    let p_public: Bool
    let p_style_ids: [Int64]
    
    init(userId: UUID, imageUrl: String, location: CLLocationCoordinate2D, locationString: String, isPublic: Bool, selectedStyles: Set<Style>) {
        self.p_user_id = userId
        self.p_image_url = imageUrl
        self.p_location = "POINT(\(location.longitude) \(location.latitude))"
        self.p_location_string = locationString
        self.p_public = isPublic
        self.p_style_ids = selectedStyles.map(\.id)
    }
}

extension Outfit: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int64.self, forKey: .id)
        createDate = try container.decode(Date.self, forKey: .createDate)
        userId = try container.decode(UUID.self, forKey: .userId)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic)
        
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        else {
            location = nil
        }
        
        styleIds = try container.decode([Int64].self, forKey: .styleIds)
        locationString = try container.decode(String.self, forKey: .locationString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createDate, forKey: .createDate)
        try container.encode(userId, forKey: .userId)
        try container.encode(imageURL, forKey: .imageURL)
        
        if let location = location {
            let geoString = "POINT(\(location.longitude) \(location.latitude))"
            try container.encode(geoString, forKey: .location)
        } else {
            try container.encodeNil(forKey: .location)
        }
        
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(locationString, forKey: .locationString)
    }
}

extension Outfit: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(createDate)
        hasher.combine(userId)
        hasher.combine(imageURL)
        if let location = location {
            hasher.combine(location.latitude)
            hasher.combine(location.longitude)
        }
        hasher.combine(isPublic)
    }
}

extension Outfit: Equatable {
    static func == (lhs: Outfit, rhs: Outfit) -> Bool {
        lhs.id == rhs.id &&
        lhs.createDate == rhs.createDate &&
        lhs.userId == rhs.userId &&
        lhs.imageURL == rhs.imageURL &&
        lhs.isPublic == rhs.isPublic &&
        lhs.location?.latitude == rhs.location?.latitude &&
        lhs.location?.longitude == rhs.location?.longitude
    }
}
