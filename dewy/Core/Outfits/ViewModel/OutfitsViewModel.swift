import SwiftUI

@MainActor
class OutfitsViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var availableStyles: [Style] = []
    @Published var loadedImages: [String: Image] = [:]
    
    private let styleService: StyleService
    
    init(styleService: StyleService) {
        self.styleService = styleService
        
        Task { await fetchStyles() }
    }
    
    func fetchStyles() async {
        do {
            self.availableStyles = try await styleService.fetchStyles()
        }
        catch {
            print("failed to fetch styles from closet vm: \(error)")
        }
    }
    
    func addOutfit(outfit: Outfit) {
        outfits.append(outfit)
        
        if let imageURL = outfit.imageURL {
            loadImage(from: imageURL)
        }
    }
    
    func fetchOutfits(userId: UUID) async throws {
        outfits = try await supabase
            .rpc("get_closet_outfits")
            .eq("user_id", value: userId)
            .execute()
            .value
    }
    
    func loadImage(from urlString: String) {
        guard loadedImages[urlString] == nil else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.loadedImages[urlString] = Image(uiImage: uiImage)
                    }
                }
            }
            catch {
                print("failed to load image: \(error)")
            }
        }
    }
}
