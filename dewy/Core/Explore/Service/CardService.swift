import Foundation

struct CardService {
    func fetchOutfitCards(userId: UUID) async throws -> [OutfitCard] {
        let outfits: [Outfit] = try await supabase
            .rpc("get_swipe_outfits", params: ["p_user_id": userId])
            .limit(3)
            .execute()
            .value
        
        return outfits.map({ OutfitCard(outfit: $0) })
    }
    
    func rateOutfit(userId: UUID, outfitId: Int64, rating: Int) async throws {
        try await supabase
            .from("Outfit_Ratings")
            .insert(
                OutfitRating(
                    outfitId: outfitId,
                    rating: rating,
                    userId: userId
                )
            )
            .execute()
            .value
    }
}
