import SwiftUI

struct CollectionsList: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var collectionsVM: CollectionsViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                
                Spacer()
                
                Text("save to collection")
                    .font(.headline)
                    .foregroundStyle(.black)
                
                Spacer()
            }
            .padding()
            
            List {
                ForEach(collectionsVM.collections) { collection in
                    CollectionItem(collection: collection)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            Task {
                                await collectionsVM.addOutfitToCollection(
                                    outfitId: collectionsVM.newCollectionOutfitId,
                                    collectionId: collection.id!,
                                    imageUrl: collectionsVM.newCollectionOutfitImageUrl
                                )
                            }
                        }
                }
            }
            .listStyle(.plain)
            .background(Color.softBeige)
            .scrollContentBackground(.hidden)
        }
        .background(Color.softBeige.ignoresSafeArea())
    }
}

struct CollectionItem: View {
    let collection: Collection
    
    var body: some View {
        HStack(spacing: 12) {
            if let firstThumbnail = collection.thumbnailUrls?.first {
                AsyncImage(url: URL(string: firstThumbnail)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Text(collection.name)
                .foregroundStyle(.black)
            
            Spacer()
        }
        .listRowBackground(Color.softBeige)
    }
}
