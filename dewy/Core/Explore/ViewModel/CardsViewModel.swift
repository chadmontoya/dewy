import SwiftUI

@MainActor
class CardsViewModel: ObservableObject {
    @Published private(set) var outfitCards = [OutfitCard]()
    @Published private(set) var isLoading = false
    @Published private(set) var preloadedImages: [String: UIImage] = [:]
    
    private let service: CardService
    private let imageCache: ImageCache = .shared
    private var preloadTask: Task<Void, Never>?
    
    init(service: CardService) {
        self.service = service
    }
    
    func fetchOutfitCards(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        preloadTask?.cancel()
        
        do {
            let cards = try await service.fetchOutfitCards(userId: userId)
            await loadImagesAndUpdateCards(cards)
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
    
    private func loadImagesAndUpdateCards(_ cards: [OutfitCard]) async {
        var validCards: [OutfitCard] = []
        var loadedImages: [String: UIImage] = [:]
        
        for card in cards {
            do {
                if let image = try await loadImage(from: card.outfit.imageURL) {
                    loadedImages[card.outfit.imageURL] = image
                    validCards.append(card)
                }
            } catch {
                print("failed to load image: \(error)")
            }
        }
        
        self.preloadedImages = loadedImages
        self.outfitCards = validCards
    }
    
    private func loadImage(from url: String) async throws -> UIImage? {
        if let cached = imageCache.image(for: url) {
            return cached
        }
        return try await imageCache.loadImage(from: url)
    }
}
