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
    
    @Published var isEditingOutfit: Bool = false
    @Published var editedStyleIds: [Int64] = []
    @Published var editedIsPublic: Bool?
    @Published var currentEditingOutfitId: Int64?
    @Published var showOutfitUpdatedToast: Bool = false
    @Published var showOutfitUpdateFailedToast: Bool = false
    
    private let imageCache: ImageCache = .shared
    private let outfitService: OutfitService
    private let styleService: StyleService
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
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
    
    func cancelOutfitEdit() {
        isEditingOutfit = false
        editedStyleIds = []
        editedIsPublic = nil
        currentEditingOutfitId = nil
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
    
    func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
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
    
    func startOutfitEdit(outfit: Outfit) {
        currentEditingOutfitId = outfit.id
        editedStyleIds = outfit.styleIds
        editedIsPublic = outfit.isPublic
        isEditingOutfit = true
    }
    
    func toggleStyleEdits(styleId: Int64) {
        if editedStyleIds.contains(styleId) {
            editedStyleIds.removeAll { $0 == styleId }
        } else {
            editedStyleIds.append(styleId)
        }
    }
    
    func toggleStyleFilter(styleId: Int64) {
        if filteredStyles.contains(styleId) {
            filteredStyles.remove(styleId)
        } else {
            filteredStyles.insert(styleId)
        }
    }
    
    func updateOutfit() async {
        guard let outfitId = currentEditingOutfitId else { return }
        
        let isPublic = editedIsPublic ?? true // default visibility of outfit is public if VM can't get from outfit
        
        Task {
            do {
                let updatedOutfit = try await outfitService.updateOutfit(
                    outfitId: outfitId,
                    isPublic: isPublic,
                    styleIds: editedStyleIds
                )
                
                await MainActor.run {
                    if let index = outfits.firstIndex(where: { $0.id == outfitId }) {
                        outfits[index] = updatedOutfit
                    }
                    showOutfitUpdatedToast = true
                    cancelOutfitEdit()
                }
            } catch {
                print("failed to update outfit: \(error)")
                await MainActor.run {
                    showOutfitUpdateFailedToast = true
                }
            }
        }
    }
}
