import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject var authController: AuthController
    @StateObject private var collectionsVM = CollectionsViewModel(collectionsService: CollectionsService())
    
    let columns = Array(repeating: GridItem(spacing: 10), count: 2)
    
    var body: some View {
        NavigationStack {
            VStack {
                headerView
                collectionGrid
            }
            .background(Color.cream.ignoresSafeArea())
            .alert("new collection", isPresented: $collectionsVM.isCreatingCollection) {
                TextField("collection name", text: $collectionsVM.newCollectionName)
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
                Text("enter a name")
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
            Spacer(minLength: 0)
            
            Button {
                collectionsVM.isCreatingCollection = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
            }
        }
        .overlay {
            Text("collections")
                .font(.title3)
                .foregroundStyle(.black)
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
