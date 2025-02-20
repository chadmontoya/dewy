import SwiftUI

@MainActor
class CollectionsViewModel: ObservableObject {
    @Published var collections: [Collection] = []
    @Published var isCreatingCollection: Bool = false
    @Published var newCollectionName: String = ""
    
    @Published var saveToCollection: Bool = false
    @Published var newCollectionOutfitId: Int64 = 0
    @Published var newCollectionOutfitImageUrl: String = ""
    
    private let collectionsService: CollectionsService
    
    init(collectionsService: CollectionsService) {
        self.collectionsService = collectionsService
    }
    
    func addOutfitToCollection(outfitId: Int64, collectionId: Int64, imageUrl: String) async {
        do {
            try await collectionsService.addOutfitToCollection(
                outfitId: outfitId,
                collectionId: collectionId,
                imageUrl: imageUrl
            )
        }
        catch {
            print("failed to add outfit to collection: \(error)")
        }
    }
    
    func fetchCollections(userId: UUID) async {
        do {
            self.collections = try await collectionsService.fetchCollections(userId: userId)
        }
        catch {
            print("failed to fetch collections: \(error)")
        }
    }
    
    func createCollection(userId: UUID) async {
        guard !newCollectionName.isEmpty else { return }
        
        do {
            let newCollection = try await collectionsService.createCollection(userId: userId, name: newCollectionName)
            collections.append(newCollection)
            newCollectionName = ""
            isCreatingCollection = false
        } catch {
            print("failed to create collection: \(error))")
        }
    }
}
