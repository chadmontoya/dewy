import Foundation

struct CardService {
    func fetchOutfitCards(userId: UUID) async throws -> [OutfitCard] {
        let outfits: [Outfit] = try await supabase
            .rpc("get_swipe_outfits", params: ["p_user_id": userId])
            .execute()
            .value
        
        return outfits.map({ OutfitCard(outfit: $0) })
    }
}
