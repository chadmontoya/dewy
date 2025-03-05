import SwiftUI

@MainActor
class CollectionsViewModel: ObservableObject {
    @Published var collections: [Collection] = []
    @Published var isCreatingCollection: Bool = false
    @Published var newCollectionName: String = ""
    @Published var showCollectionAddedToast: Bool = false
    @Published var showCollectionDeletedToast: Bool = false
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
    
    func deleteCollection(collectionId: Int64) async {
        do {
            try await collectionService.deleteCollection(collectionId: collectionId)
            if let index = collections.firstIndex(where: { $0.id == collectionId }) {
                collections.remove(at: index)
                showCollectionDeletedToast = true
            }
        } catch {
            print("error deleting collection: \(error)")
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
    
    func fetchThumbnailUrls(for collectionId: Int64) async {
        if let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }) {
            collections[collectionIndex].thumbnailUrls = await collectionService.fetchCollectionThumbnailUrls(collectionId: collectionId)
        }
    }
    
    func handleAddCollectionOutfit(collectionId: Int64, amount: Int = 1, thumbnailURL: String) {
        if let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }) {
            collections[collectionIndex].itemCount += amount
            
            if collections[collectionIndex].thumbnailUrls.count < 3,
               !collections[collectionIndex].thumbnailUrls.contains(thumbnailURL) {
                
                collections[collectionIndex].thumbnailUrls.append(thumbnailURL)
            }
        }
    }
    
    func handleRemoveCollectionOutfit(collectionId: Int64, amount: Int = 1, thumbnailUrl: String) async {
        guard let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        
        collections[collectionIndex].itemCount -= amount
        
        if collections[collectionIndex].thumbnailUrls.contains(thumbnailUrl) {
            collections[collectionIndex].thumbnailUrls.removeAll(where: { $0 == thumbnailUrl })
            await fetchThumbnailUrls(for: collectionId)
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
