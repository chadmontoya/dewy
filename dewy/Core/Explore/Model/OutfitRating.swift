import Foundation

struct OutfitRating: Codable {
    var id: Int64?
    var createDate: Date?
    var outfitId: Int64
    var rating: Int
    var userId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createDate = "created_at"
        case outfitId = "outfit_id"
        case rating
        case userId = "user_id"
    }
    
    init(outfitId: Int64, rating: Int, userId: UUID) {
        self.id = nil
        self.createDate = Date()
        self.outfitId = outfitId
        self.rating = rating
        self.userId = userId
    }
}
