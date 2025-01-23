import Foundation

struct Style: Codable, Identifiable {
    let id: Int64
    let name: String
}

struct OutfitStyle: Encodable {
    let outfitId: Int64
    let styleId: Int64
    
    enum CodingKeys: String, CodingKey {
        case outfitId = "outfit_id"
        case styleId = "style_id"
    }
}
