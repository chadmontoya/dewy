import Foundation

struct OutfitService {
    func fetchSwipeOutfits(userId: UUID) async throws {
        try await supabase
            .rpc("get_swipe_outfits", params: ["p_user_id": userId])
            .execute()
            .value
    }
}
