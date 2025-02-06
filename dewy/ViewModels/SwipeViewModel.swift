import SwiftUI

class SwipeViewModel: ObservableObject {
    
    private let outfitService: OutfitService
    
    init(outfitService: OutfitService) {
        self.outfitService = outfitService
    }
    
    func fetchOutfits(userId: UUID) async throws {
        do {
            try await outfitService.fetchSwipeOutfits(userId: userId)
        }
        catch {
            print("failed to get swipe outfits: \(error)")
        }
    }
}
