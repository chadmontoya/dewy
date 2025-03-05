import Foundation

struct Collection: Identifiable, Hashable {
    var id: Int64?
    var userId: UUID
    var name: String
    var createDate: Date?
    var thumbnailUrls: [String] = []
    var itemCount: Int = 0
    
    init(userId: UUID, name: String) {
        self.id = nil
        self.userId = userId
        self.name = name
        self.createDate = Date()
    }
}

extension Collection: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userId = "user_id"
        case createDate = "created_at"
        case thumbnailUrls = "thumbnail_urls"
        case itemCount = "item_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        userId = try container.decode(UUID.self, forKey: .userId)
        createDate = try container.decodeIfPresent(Date.self, forKey: .createDate)
        thumbnailUrls = try container.decodeIfPresent([String].self, forKey: .thumbnailUrls) ?? []
        itemCount = try container.decodeIfPresent(Int.self, forKey: .itemCount) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(createDate, forKey: .createDate)
    }
}
