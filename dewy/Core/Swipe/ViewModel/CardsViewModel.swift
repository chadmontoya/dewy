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
            print("failed to fetch cards: \(error)")
        }
    }
    
    func removeOutfitCard(_ card: OutfitCard) {
        guard let index = outfitCards.firstIndex(where: {$0.id == card.id }) else { return }
        outfitCards.remove(at: index)
    }
}
