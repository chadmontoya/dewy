import SwiftUI
import MapKit

struct Outfit: Codable, Identifiable, Hashable {
    let id: Int64?
    let createDate: Date?
    let userId: UUID?
    let imageURL: String?
    let location: CLLocationCoordinate2D?
    let isPublic: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createDate = "created_at"
        case userId = "user_id"
        case imageURL = "image_url"
        case location
        case isPublic = "public"
    }
    
    init(userId: UUID, createDate: Date = Date(), imageURL: String? = nil, location: CLLocationCoordinate2D? = nil, isPublic: Bool? = nil) {
        self.id = nil
        self.createDate = createDate
        self.userId = userId
        self.imageURL = imageURL
        self.location = location
        self.isPublic = isPublic
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int64.self, forKey: .id)
        createDate = try container.decodeIfPresent(Date.self, forKey: .createDate)
        userId = try container.decode(UUID.self, forKey: .userId)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic)
        
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
