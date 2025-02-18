import Foundation

struct CollectionsService {
    func createCollection(userId: UUID, name: String) {
        
    }
    
    func deleteCollection(collectionId: Int64) {
        
    }
    
    func fetchOutfitsInCollection(collectionId: Int64) -> [Outfit] {
        return []
    }
    
    func fetchCollections(userId: UUID) -> [Collection] {
        return []
    }
    
    func saveOutfitToCollection(outfitId: Int64, collectionId: Int64) {
        
    }
}
