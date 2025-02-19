import Foundation

struct CollectionsService {
    func createCollection(userId: UUID, name: String) async throws -> Collection {
        let collection: Collection = Collection(userId: userId, name: name)
        try await supabase
            .from("Collections")
            .insert(collection)
            .execute()
        
        return collection
    }
    
    func deleteCollection(collectionId: Int64) async throws {
    }
    
    func fetchOutfitsInCollection(collectionId: Int64) -> [Outfit] {
        return []
    }
    
    func fetchCollections(userId: UUID) async throws -> [Collection] {
        var collections: [Collection] = []
        collections = try await supabase
            .rpc("get_collections", params: ["p_user_id": userId])
            .execute()
            .value
        return collections
    }
    
    func saveOutfitToCollection(outfitId: Int64, collectionId: Int64) {
        
    }
}
