import Foundation

struct Collection {
    var id: Int64?
    var userId: UUID
    var name: String
    var createDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userId = "user_id"
        case createDate = "created_at"
    }
    
    init(userId: UUID, name: String) {
        self.id = 0
        self.createDate = Date()
        self.userId = userId
        self.name = name
    }
}
