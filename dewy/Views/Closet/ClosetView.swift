import SwiftUI

struct ClosetView: View {
    @Binding var uploadOutfit: Bool
    @EnvironmentObject var authController: AuthController
    @Namespace private var animation
    @State private var selectedOutfitImage: Image? = nil
    @StateObject private var closetVM: ClosetViewModel = ClosetViewModel()
    
    
    let columns = Array(repeating: GridItem(spacing: 10), count: 2)
    
    var body: some View {
        GeometryReader {
            let screenSize: CGSize = $0.size
            ZStack {
                Color.cream.ignoresSafeArea()
                NavigationStack {
                    VStack {
                        Button {
                            uploadOutfit = true
                        } label: {
                            Text("Upload Outfit")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .background(Color.coffee)
                        }
                        .cornerRadius(10)
                        
                        outfitList(screenSize: screenSize)
                    }
                    .navigationDestination(for: Outfit.self) { outfit in
                        OutfitDetailView(outfit: outfit, animation: animation)
                            .toolbarVisibility(.hidden, for: .navigationBar)
                    }
                }
            }
        }
        .onAppear {
            Task {
                try await closetVM.fetchOutfits(userId: authController.currentUserId)
            }
        }
    }
    
    func outfitList(screenSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(closetVM.outfits) { outfit in
                    NavigationLink(value: outfit) {
                        OutfitCardView(screenSize: screenSize, outfit: outfit)
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

struct OutfitCardView: View {
    var screenSize: CGSize
    var outfit: Outfit
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            if let imageURL = outfit.imageURL {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size.width, height: size.height)
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    case .failure:
                        Image(systemName: "photo")
                            .frame(width: size.width, height: size.height)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
}
