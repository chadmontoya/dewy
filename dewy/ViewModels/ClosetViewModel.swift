import SwiftUI

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var loadedImages: [String: Image] = [:]
    
    func fetchOutfits(userId: UUID) async throws {
        outfits = try await supabase
            .from("Outfits")
            .select()
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
