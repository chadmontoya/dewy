import Foundation

@MainActor
class CardsViewModel: ObservableObject {
    @Published var outfitCards = [OutfitCard]()
    
    private let service: CardService
    
    init(service: CardService) {
        self.service = service
    }
    
    func fetchOutfitCards(userId: UUID) async {
        do {
            self.outfitCards = try await service.fetchOutfitCards(userId: userId)
        } catch {
            print("failed to fetch outfit cards: \(error)")
        }
    }
    
    func rateOutfit(userId: UUID, outfitId: Int64, rating: Int) async {
        do {
            try await service.rateOutfit(userId: userId, outfitId: outfitId, rating: rating)
        } catch {
            print("failed to rate outfit: \(error)")
        }
    }
    
    func removeOutfitCard(_ card: OutfitCard) {
        guard let index = outfitCards.firstIndex(where: {$0.id == card.id }) else { return }
        outfitCards.remove(at: index)
    }
}
