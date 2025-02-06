import SwiftUI
import CoreLocation

struct Outfit: Identifiable {
    var id: Int64
    var createDate: Date?
    var userId: UUID?
    var imageURL: String?
    var location: CLLocationCoordinate2D?
    var isPublic: Bool?
    var styleIds: [Int64]?
    
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
    }
    
    init(userId: UUID, createDate: Date = Date(), imageURL: String? = nil, location: CLLocationCoordinate2D? = nil, isPublic: Bool? = nil, styleIds: [Int64]? = []) {
        self.id = 0
        self.createDate = createDate
        self.userId = userId
        self.imageURL = imageURL
        self.location = location
        self.isPublic = isPublic
        self.styleIds = styleIds
    }
}

extension Outfit: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int64.self, forKey: .id)
        createDate = try container.decodeIfPresent(Date.self, forKey: .createDate)
        userId = try container.decode(UUID.self, forKey: .userId)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic)
        
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        else {
            location = nil
        }
        
        styleIds = try container.decodeIfPresent([Int64].self, forKey: .styleIds)
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
