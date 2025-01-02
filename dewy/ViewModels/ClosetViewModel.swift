import SwiftUI

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    
    func fetchOutfits(userId: UUID) async throws {
        outfits = try await supabase
            .from("Outfits")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
    }
}
