import SwiftUI

class OutfitsViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var availableStyles: [Style] = []
    @Published var loadedImages: [String: Image] = [:]
    
    private let imageLoader = AsyncImageLoader()
    
    private let outfitService: OutfitService
    private let styleService: StyleService
    
    init(outfitService: OutfitService, styleService: StyleService) {
        self.outfitService = outfitService
        self.styleService = styleService
        
        Task { await fetchStyles() }
    }
    
    func fetchStyles() async {
        let styles: [Style] = await styleService.fetchStyles()
        await MainActor.run {
            self.availableStyles = styles
        }
    }
    
    func addOutfit(outfit: Outfit) {
        if let imageURL = outfit.imageURL {
            loadImage(from: imageURL)
        }
        outfits.insert(outfit, at: 0)
    }
    
    func fetchOutfits(userId: UUID) async {
        let outfits: [Outfit] = await outfitService.fetchUsersOutfits(userId: userId)
        await MainActor.run {
            self.outfits = outfits
        }
    }
    
    func loadImage(from urlString: String) {
        guard loadedImages[urlString] == nil else { return }
        
        Task {
            do {
                if let uiImage = try await imageLoader.downloadImage(urlString: urlString) {
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
