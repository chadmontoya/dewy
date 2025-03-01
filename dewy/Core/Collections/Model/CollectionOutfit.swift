import Foundation

struct CollectionOutfit: Codable, Identifiable {
    let id: Int64?
    let collectionId: Int64?
    let outfitId: Int64?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case collectionId = "collection_id"
        case outfitId = "outfit_id"
        case imageUrl = "image_url"
    }
    
    init(collectionId: Int64, outfitId: Int64, imageUrl: String) {
        self.id = nil
        self.collectionId = collectionId
        self.outfitId = outfitId
        self.imageUrl = imageUrl
    }
}
