import SwiftUI

class OutfitsViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var availableStyles: [Style] = []
    @Published var loadedImages: [String: Image] = [:]
    @Published var showOutfitDeletedToast: Bool = false
    @Published var showOutfitAddedToast: Bool = false
    
    private let imageCache: ImageCache = .shared
    private let outfitService: OutfitService
    private let styleService: StyleService
    
    init(outfitService: OutfitService, styleService: StyleService) {
        self.outfitService = outfitService
        self.styleService = styleService
        
        Task { await fetchStyles() }
    }
    
    func addOutfit(outfit: Outfit) {
        if let imageURL = outfit.imageURL {
            loadImage(from: imageURL)
        }
        outfits.insert(outfit, at: 0)
    }
    
    func deleteOutfit(outfitId: Int64) async {
        do {
            try await outfitService.deleteOutfit(outfitId: outfitId)
            await MainActor.run {
                if let index = outfits.firstIndex(where: { $0.id == outfitId }),
                   let imageURL = outfits[index].imageURL {
                    imageCache.removeImage(for: imageURL)
                    loadedImages.removeValue(forKey: imageURL)
                    outfits.remove(at: index)
                }
            }
        } catch {
            print("error deleting outfit: \(error)")
        }
    }
    
    func fetchOutfits(userId: UUID) async {
        let outfits: [Outfit] = await outfitService.fetchUsersOutfits(userId: userId)
        await MainActor.run {
            self.outfits = outfits
        }
    }
    
    func fetchStyles() async {
        let styles: [Style] = await styleService.fetchStyles()
        await MainActor.run {
            self.availableStyles = styles
        }
    }
    
    func loadImage(from urlString: String) {
        guard loadedImages[urlString] == nil else { return }
        
        Task {
            do {
                if let uiImage = try await imageCache.loadImage(from: urlString) {
                    await MainActor.run {
                        self.loadedImages[urlString] = Image(uiImage: uiImage)
                    }
                }
            } catch {
                print("failed to load outfit image: \(error)")
            }
        }
    }
}
