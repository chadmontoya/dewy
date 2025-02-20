import SwiftUI

struct OutfitsView: View {
    @EnvironmentObject var authController: AuthController
    @Namespace private var animation
    @State private var uploadOutfit: Bool = false
    @State private var navigationPath: [String] = []
    @StateObject private var outfitsVM = OutfitsViewModel(styleService: StyleService())
    
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
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    
                    OutfitList(screenSize: UIScreen.main.bounds.size)
                }
                .background(Color.cream.ignoresSafeArea())
                .navigationDestination(for: Outfit.self) { outfit in
                    OutfitDetailView(outfit: outfit, animation: animation, outfitsVM: outfitsVM)
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
            .environmentObject(outfitsVM)
        }
        .onAppear {
            Task {
                if let userId = authController.session?.user.id {
                    try await outfitsVM.fetchOutfits(userId: userId)
                }
            }
        }
    }
    
    func OutfitList(screenSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(outfitsVM.outfits) { outfit in
                    NavigationLink(value: outfit) {
                        OutfitCardView(screenSize: screenSize, outfit: outfit, outfitsVM: outfitsVM)
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
        .scrollIndicators(.hidden)
    }
}
