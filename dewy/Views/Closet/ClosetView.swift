import SwiftUI

struct ClosetView: View {
    @EnvironmentObject var authController: AuthController
    @Namespace private var animation
    @State private var uploadOutfit: Bool = false
    @State private var navigationPath: [String] = []
    @StateObject private var closetVM: ClosetViewModel = ClosetViewModel()
    
    let columns = Array(repeating: GridItem(spacing: 10), count: 2)
    
    var body: some View {
        Group {
            NavigationStack {
                VStack {
                    HStack {
                        Spacer(minLength: 0)
                        
                        Button {
                            uploadOutfit = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                        }
                    }
                    .overlay {
                        Text("outfits")
                            .font(.title3)
                            .foregroundStyle(Color.coffee)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    
                    OutfitList(screenSize: UIScreen.main.bounds.size)
                }
                .background(Color.cream.ignoresSafeArea())
                .navigationDestination(for: Outfit.self) { outfit in
                    OutfitDetailView(outfit: outfit, animation: animation, closetVM: closetVM)
                        .toolbarVisibility(.hidden, for: .navigationBar)
                }
                .navigationDestination(isPresented: $uploadOutfit) {
                    UploadOutfitView(onComplete: {
                        uploadOutfit = false
                        navigationPath.removeAll()
                    })
                        .toolbarRole(.editor)
                }
            }
        }
        .onAppear {
            Task {
                try await closetVM.fetchOutfits(userId: authController.currentUserId)
            }
        }
    }
    
    func OutfitList(screenSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(closetVM.outfits) { outfit in
                    NavigationLink(value: outfit) {
                        OutfitCardView(screenSize: screenSize, outfit: outfit, closetVM: closetVM)
                            .frame(height: screenSize.height * 0.4)
                            .matchedTransitionSource(id: outfit.id, in: animation) {
                                $0
                                    .background(.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                    }
                }
            }
            .padding()
        }
    }
}
