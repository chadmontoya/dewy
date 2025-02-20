import Foundation

struct CollectionsService {
    func addOutfitToCollection(outfitId: Int64, collectionId: Int64, imageUrl: String) async throws {
        let collectionOutfit: CollectionOutfit = CollectionOutfit(
            collectionId: collectionId,
            outfitId: outfitId,
            imageUrl: imageUrl
        )
        
        try await supabase
            .from("Collections_Outfits")
            .insert(collectionOutfit)
            .execute()
    }
    
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
}
