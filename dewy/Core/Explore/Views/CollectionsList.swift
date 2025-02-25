import SwiftUI

struct CollectionsList: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var collectionsVM: CollectionsViewModel
    @State private var pressedCollectionId: Int64? = nil
    
    var body: some View {
        VStack {
            Spacer()
            
            CollectionsHeader(dismiss: dismiss)
            
            List {
                ForEach(collectionsVM.collections) { collection in
                    CollectionListItem(
                        collection: collection,
                        pressedCollectionId: pressedCollectionId,
                        onTap: {
                            withAnimation(.easeInOut) {
                                pressedCollectionId = collection.id
                            }
                            collectionsVM.selectedCollection = collection
                            collectionsVM.showingConfirmationAlert = true
                        }
                    )
                }
            }
            .listStyle(.plain)
            .background(Color.primaryBackground)
            .scrollContentBackground(.hidden)
        }
        .background(Color.primaryBackground.ignoresSafeArea())
        .confirmationDialog("Save to Collection", isPresented: $collectionsVM.showingConfirmationAlert, titleVisibility: .hidden) {
            Button("Confirm") {
                Task {
                    if let collection = collectionsVM.selectedCollection {
                        await collectionsVM.addOutfitToCollection(
                            outfitId: collectionsVM.newCollectionOutfitId,
                            collectionId: collection.id!,
                            imageUrl: collectionsVM.newCollectionOutfitImageUrl
                        )
                        dismiss()
                    }
                }
            }
            
            Button("Cancel", role: .cancel) {
                withAnimation(.easeOut(duration: 0.2)) {
                    pressedCollectionId = nil
                }
                collectionsVM.selectedCollection = nil
            }
        } message: {
            Text("Are you sure you want to add this outfit to \(collectionsVM.selectedCollection?.name ?? "")?")
        }
    }
}

private struct CollectionsHeader: View {
    let dismiss: DismissAction
    
    var body: some View {
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
    }
}

private struct CollectionListItem: View {
    let collection: Collection
    let pressedCollectionId: Int64?
    let onTap: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await onTap()
            }
        } label: {
            CollectionItem(collection: collection)
                .scaleEffect(pressedCollectionId == collection.id ? 0.95 : 1.0)
                .opacity(pressedCollectionId == collection.id ? 0.7 : 1.0)
        }
        .buttonStyle(PressableButtonStyle())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.primaryBackground)
    }
}

private struct CollectionItem: View {
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
        .contentShape(Rectangle())
    }
}

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.4) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}
