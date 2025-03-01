import SwiftUI

@MainActor
class CollectionsViewModel: ObservableObject {
    @Published var collections: [Collection] = []
    @Published var isCreatingCollection: Bool = false
    @Published var newCollectionName: String = ""
    @Published var showCollectionAddedToast: Bool = false
    @Published var showCollectionDeleteToast: Bool = false
    @Published var saveToCollection: Bool = false
    @Published var newCollectionOutfitId: Int64 = 0
    @Published var newCollectionOutfitImageUrl: String = ""
    @Published var showingConfirmationAlert: Bool = false
    @Published var selectedCollection: Collection? = nil
    @Published var showOutfitAddedToast: Bool = false
    @Published var loadedImages: [String: Image] = [:]
    
    private let imageCache: ImageCache = .shared
    private let collectionService: CollectionService
    
    init(collectionService: CollectionService) {
        self.collectionService = collectionService
    }
    
    func addOutfitToCollection(outfitId: Int64, collectionId: Int64, imageUrl: String) async {
        do {
            try await collectionService.addOutfitToCollection(
                outfitId: outfitId,
                collectionId: collectionId,
                imageUrl: imageUrl
            )
            handleAddCollectionOutfit(collectionId: collectionId, thumbnailURL: imageUrl)
            showOutfitAddedToast = true
        }
        catch {
            print("failed to add outfit to collection: \(error)")
        }
    }
    
    func createCollection(userId: UUID) async {
        guard !newCollectionName.isEmpty else { return }
        
        do {
            let newCollection = try await collectionService.createCollection(userId: userId, name: newCollectionName)
            collections.insert(newCollection, at: 0)
            showCollectionAddedToast = true
            newCollectionName = ""
            isCreatingCollection = false
        } catch {
            print("failed to create collection: \(error))")
        }
    }
    
    func fetchCollections(userId: UUID) async {
        do {
            self.collections = try await collectionService.fetchCollections(userId: userId)
        }
        catch {
            print("failed to fetch collections: \(error)")
        }
    }
    
    func handleAddCollectionOutfit(collectionId: Int64, amount: Int = 1, thumbnailURL: String) {
        if let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }) {
            collections[collectionIndex].itemCount! += amount
            
            if let thumbnailUrls = collections[collectionIndex].thumbnailUrls,
               thumbnailUrls.count < 3,
               !thumbnailUrls.contains(thumbnailURL) {
                print("not enough thumbnails, adding url")
                collections[collectionIndex].thumbnailUrls?.append(thumbnailURL)
            }
        }
    }
    
    func handleRemoveCollectionOutfit(collectionId: Int64, amount: Int = 1, thumbnailURL: String) {
        if let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }) {
            collections[collectionIndex].itemCount! -= amount
            
            if let thumbnailIndex = collections[collectionIndex].thumbnailUrls?.firstIndex(of: thumbnailURL) {
                collections[collectionIndex].thumbnailUrls?.remove(at: thumbnailIndex)
            }
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
