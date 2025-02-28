import SwiftUI

struct CollectionOutfitsView: View {
    @State private var collectionOutfits: [CollectionOutfit] = []
    
    var collection: Collection
    var animation: Namespace.ID
    
    @EnvironmentObject var collectionsVM: CollectionsViewModel
    @Environment(\.dismiss) private var dismissView
    
    let columns = Array(repeating: GridItem(spacing: 10), count: 2)
    
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
        .task {
            if collectionOutfits.isEmpty {
                if let collectionId = collection.id {
                    collectionOutfits = await collectionsVM.fetchCollectionOutfits(collectionId: collectionId)
                }
            }
        }
        .background(Color.primaryBackground.ignoresSafeArea())
        .navigationTransition(.zoom(sourceID: collection.id, in: animation))
        .navigationAllowDismissalGestures(.edgePanGesturesOnly)
    }
    
    func CollectionOutfitList(screenSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(collectionOutfits) { collectionOutfit in
                    CollectionOutfitCard(imageURL: collectionOutfit.imageUrl)
                        .frame(height: screenSize.height * 0.4)
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

struct CollectionOutfitCard: View {
    @EnvironmentObject var collectionsVM: CollectionsViewModel
    
    var imageURL: String?
    
    var body: some View {
        GeometryReader { geometry in
            if let imageURL = imageURL {
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
    }
}
