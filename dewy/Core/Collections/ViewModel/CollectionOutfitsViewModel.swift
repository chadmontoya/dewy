import SwiftUI

class CollectionOutfitsViewModel: ObservableObject {
    @Published var collectionOutfits: [CollectionOutfit] = []
    @Published var showCollectionOutfitDeleted: Bool = false
    
    private let imageCache: ImageCache = .shared
    private let collectionService: CollectionService
    
    init(collectionService: CollectionService) {
        self.collectionService = collectionService
        
    }
    
    func fetchCollectionOutfits(collectionId: Int64) async {
        do {
            let fetchedOutfits = try await collectionService.fetchCollectionOutfits(collectionId: collectionId)
            await MainActor.run {
                self.collectionOutfits = fetchedOutfits
            }
        } catch {
            print("failed to fetch collection outfits: \(error)")
        }
    }
    
    func deleteCollectionOutfit(collectionOutfitId: Int64) async {
        do {
            try await collectionService.deleteCollectionOutfit(collectionOutfitId: collectionOutfitId)
            await MainActor.run {
                if let index = collectionOutfits.firstIndex(where: { $0.id == collectionOutfitId }),
                   let imageURL = collectionOutfits[index].imageUrl {
                    imageCache.removeImage(for: imageURL)
                    collectionOutfits.remove(at: index)
                    showCollectionOutfitDeleted = true
                }
            }
        } catch {
            print("failed to delete outfit collection: \(error)")
        }
    }
}
