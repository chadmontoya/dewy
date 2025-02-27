import SwiftUI
import SimpleToast

struct CollectionsView: View {
    @EnvironmentObject var authController: AuthController
    
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
                headerView
                collectionGrid
            }
            .background(Color.primaryBackground.ignoresSafeArea())
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
        }
        .onAppear {
            if let userId = authController.session?.user.id {
                Task {
                    await collectionsVM.fetchCollections(userId: userId)
                }
            }
        }
    }
    
    private var headerView: some View {
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
    }
    
    private var collectionGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(collectionsVM.collections) { collection in
                    VStack(alignment: .leading, spacing: 8) {
                        CollectionCard(
                            screenSize: UIScreen.main.bounds.size,
                            collection: collection
                        )
                        .frame(height: UIScreen.main.bounds.height * 0.2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(collection.name)
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(.black)
                            
                            Text("\(String(collection.itemCount ?? 0)) items")
                                .font(.caption)
                                .foregroundStyle(.black.opacity(0.8))
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}
