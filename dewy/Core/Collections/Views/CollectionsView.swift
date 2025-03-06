import SwiftUI
import SimpleToast

struct CollectionsView: View {
    @EnvironmentObject var authController: AuthController
    @Namespace private var animation
    @ObservedObject var collectionsVM: CollectionsViewModel
    
    let columns = Array(repeating: GridItem(spacing: 10), count: 2)
    
    private let toastOptions = SimpleToastOptions(
        alignment: .top,
        hideAfter: 4,
        animation: .easeInOut,
        modifierType: .slide
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("collections")
                        .font(.title3)
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Button {
                        collectionsVM.isCreatingCollection = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                
                CollectionsGridView(
                    collections: collectionsVM.collections,
                    columns: columns,
                    animation: animation,
                    onDelete: { collectionId in
                        Task {
                            await collectionsVM.deleteCollection(collectionId: collectionId)
                        }
                    }
                )
            }
            .background(Color.primaryBackground.ignoresSafeArea())
            .navigationDestination(for: Collection.self) { collection in
                CollectionOutfitsView(collection: collection, animation: animation)
                    .toolbarVisibility(.hidden, for: .navigationBar)
            }
            .alert("New Collection", isPresented: $collectionsVM.isCreatingCollection) {
                TextField("Name", text: $collectionsVM.newCollectionName)
                Button("Cancel", role: .cancel) {
                    collectionsVM.newCollectionName = ""
                }
                Button("Create") {
                    if let userId = authController.session?.user.id {
                        Task {
                            await collectionsVM.createCollection(userId: userId)
                        }
                    }
                }
            } message: {
                Text("Enter a name")
            }
            .simpleToast(isPresented: $collectionsVM.showCollectionAddedToast, options: toastOptions) {
                ToastMessage(iconName: "checkmark.circle", message: "Successfully created a new collection")
            }
            .simpleToast(isPresented: $collectionsVM.showCollectionDeletedToast, options: toastOptions) {
                ToastMessage(iconName: "checkmark.circle", message: "Successfully deleted the collection")
            }
        }
        .environmentObject(collectionsVM)
        .task {
            if let userId = authController.session?.user.id,
               collectionsVM.collections.isEmpty {
                await collectionsVM.fetchCollections(userId: userId)
            }
        }
    }
}

struct CollectionsGridView: View {
    let collections: [Collection]
    let columns: [GridItem]
    var animation: Namespace.ID
    var onDelete: (Int64) -> Void
    
    @State private var showDeleteConfirmation = false
    @State private var selectedCollectionId: Int64?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(collections) { collection in
                    CollectionGridItem(
                        collection: collection,
                        animation: animation,
                        onDeleteTapped: {
                            selectedCollectionId = collection.id
                            showDeleteConfirmation = true
                        }
                    )
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .confirmationDialog("Delete Collection", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let id = selectedCollectionId {
                    onDelete(id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure want to delete this collection? All outfits inside will also be deleted")
        }
    }
}

struct CollectionGridItem: View {
    let collection: Collection
    var animation: Namespace.ID
    var onDeleteTapped: () -> Void
    
    var body: some View {
        NavigationLink(value: collection) {
            VStack(alignment: .leading, spacing: 8) {
                CollectionCard(
                    screenSize: UIScreen.main.bounds.size,
                    collection: collection
                )
                .frame(height: UIScreen.main.bounds.height * 0.2)
                .contextMenu {
                    Button(role: .destructive) {
                        onDeleteTapped()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                
                CollectionItemInfo(collection: collection)
                    .padding(.horizontal, 4)
            }
            .matchedTransitionSource(id: collection.id, in: animation) {
                $0
                    .background(.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}

struct CollectionItemInfo: View {
    let collection: Collection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(collection.name)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.black)
            
            Text("\(String(collection.itemCount)) items")
                .font(.caption)
                .foregroundStyle(.black.opacity(0.8))
        }
    }
}
