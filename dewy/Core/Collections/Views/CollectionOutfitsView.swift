import SwiftUI
import SimpleToast

struct CollectionOutfitsView: View {
    @Environment(\.dismiss) private var dismissView
    
    @StateObject private var collectionOutfitsVM = CollectionOutfitsViewModel(
        collectionService: CollectionService()
    )
    
    private let columns = Array(repeating: GridItem(spacing: 10), count: 2)
    private let toastOptions = SimpleToastOptions(
        alignment: .top,
        hideAfter: 4,
        animation: .easeInOut,
        modifierType: .slide
    )
    
    var collection: Collection
    var animation: Namespace.ID
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismissView()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                
                Spacer()
                
                Text(collection.name)
                    .font(.title3)
                    .foregroundStyle(.black)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            
            CollectionOutfitList(screenSize: UIScreen.main.bounds.size)
        }
        .environmentObject(collectionOutfitsVM)
        .task {
            if collectionOutfitsVM.collectionOutfits.isEmpty {
                if let collectionId = collection.id {
                    await collectionOutfitsVM.fetchCollectionOutfits(collectionId: collectionId)
                }
            }
        }
        .background(Color.primaryBackground.ignoresSafeArea())
        .navigationTransition(.zoom(sourceID: collection.id, in: animation))
        .navigationAllowDismissalGestures(.edgePanGesturesOnly)
        .simpleToast(isPresented: $collectionOutfitsVM.showCollectionOutfitDeleted, options: toastOptions) {
            ToastMessage(iconName: "checkmark.circle", message: "Successfully removed outfit from \(collection.name)")
        }
    }
    
    func CollectionOutfitList(screenSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(collectionOutfitsVM.collectionOutfits) { collectionOutfit in
                    CollectionOutfitCard(collectionOutfit: collectionOutfit, collectionName: collection.name)
                        .frame(height: screenSize.height * 0.4)
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

struct CollectionOutfitCard: View {
    @EnvironmentObject var collectionOuftitsVM: CollectionOutfitsViewModel
    @EnvironmentObject var collectionsVM: CollectionsViewModel
    
    @State private var showRemoveConfirmation: Bool = false
    
    var collectionOutfit: CollectionOutfit
    var collectionName: String
    
    var body: some View {
        GeometryReader { geometry in
            if let imageURL = collectionOutfit.imageUrl {
                if let outfitImage = collectionsVM.loadedImages[imageURL] {
                    outfitImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                else {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onAppear {
                            collectionsVM.loadImage(from: imageURL)
                        }
                }
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                Task {
                    showRemoveConfirmation = true
                }
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
        .confirmationDialog("Remove Outfit Collection", isPresented: $showRemoveConfirmation) {
            Button("Remove", role: .destructive) {
                Task {
                    if let collectionOutfitId = collectionOutfit.id,
                       let collectionId = collectionOutfit.collectionId,
                       let imageURL = collectionOutfit.imageUrl {
                        await collectionOuftitsVM.deleteCollectionOutfit(collectionOutfitId: collectionOutfitId)
                        collectionsVM.handleRemoveCollectionOutfit(collectionId: collectionId, thumbnailURL: imageURL)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove this outfit from \(collectionName)")
        }
    }
}
