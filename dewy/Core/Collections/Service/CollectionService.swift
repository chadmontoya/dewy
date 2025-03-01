import Foundation

struct CollectionService {
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
        let collection: Collection = try await supabase
            .from("Collections")
            .insert(Collection(userId: userId, name: name))
            .select()
            .single()
            .execute()
            .value
        
        return collection
    }
    
    func deleteCollection(collectionId: Int64) async throws {
    }
    
    func deleteCollectionOutfit(collectionOutfitId: Int64) async throws {
        try await supabase
            .from("Collections_Outfits")
            .delete()
            .eq("id", value: String(collectionOutfitId))
            .execute()
    }
    
    func fetchCollectionOutfits(collectionId: Int64) async throws -> [CollectionOutfit] {
        var collectionOutfits: [CollectionOutfit] = []
        collectionOutfits = try await supabase
            .from("Collections_Outfits")
            .select()
            .eq("collection_id", value: String(collectionId))
            .execute()
            .value
        return collectionOutfits
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
