import SwiftUI

enum SortOrder: String, CaseIterable, Identifiable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    
    var id: String { self.rawValue }
}

class OutfitsViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var availableStyles: [Style] = []
    @Published var loadedImages: [String: Image] = [:]
    @Published var showOutfitDeletedToast: Bool = false
    @Published var showOutfitAddedToast: Bool = false
    @Published var uploadOutfit: Bool = false
    
    @Published var sortOrder: SortOrder = .newestFirst
    @Published var isCompactGrid: Bool = false
    @Published var filteredStyles: Set<Int64> = []
    @Published var showFilterMenu: Bool = false
    
    private let imageCache: ImageCache = .shared
    private let outfitService: OutfitService
    private let styleService: StyleService
    
    var filteredAndSortedOutfits: [Outfit] {
        var result = outfits
        
        if !filteredStyles.isEmpty {
            result = result.filter { outfit in
                return !Set(outfit.styleIds).isDisjoint(with: filteredStyles)
            }
        }
        
        switch sortOrder {
        case .newestFirst:
            result.sort { $0.createDate > $1.createDate }
        case .oldestFirst:
            result.sort { $0.createDate < $1.createDate }
        }
        
        return result
    }
    
    init(outfitService: OutfitService, styleService: StyleService) {
        self.outfitService = outfitService
        self.styleService = styleService
        
        Task { await fetchStyles() }
    }
    
    func addOutfit(outfit: Outfit) {
        loadImage(from: outfit.imageURL)
        outfits.insert(outfit, at: 0)
    }
    
    func clearStyleFilters() {
        filteredStyles.removeAll()
    }
    
    func deleteOutfit(outfitId: Int64) async {
        do {
            try await outfitService.deleteOutfit(outfitId: outfitId)
            await MainActor.run {
                if let index = outfits.firstIndex(where: { $0.id == outfitId }) {
                    imageCache.removeImage(for: outfits[index].imageURL)
                    loadedImages.removeValue(forKey: outfits[index].imageURL)
                    outfits.remove(at: index)
                    showOutfitDeletedToast = true
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
    
    func toggleStyleFilter(styleId: Int64) {
        if filteredStyles.contains(styleId) {
            filteredStyles.remove(styleId)
        } else {
            filteredStyles.insert(styleId)
        }
    }
}
