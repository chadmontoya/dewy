import SwiftUI

struct ClosetView: View {
    @Binding var uploadOutfit: Bool
    @EnvironmentObject var authController: AuthController
    @Namespace private var animation
    @StateObject private var closetVM: ClosetViewModel = ClosetViewModel()
    
    
    let columns = Array(repeating: GridItem(spacing: 10), count: 2)
    
    var body: some View {
        GeometryReader {
            let screenSize: CGSize = $0.size
            ZStack {
                Color.cream.ignoresSafeArea()
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
                        
                        OutfitList(screenSize: screenSize)
                    }
                    .navigationDestination(for: Outfit.self) { outfit in
                        OutfitDetailView(outfit: outfit, animation: animation, closetVM: closetVM)
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

struct OutfitCardView: View {
    var screenSize: CGSize
    var outfit: Outfit
    @ObservedObject var closetVM: ClosetViewModel
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            if let imageURL = outfit.imageURL {
                if let outfitImage = closetVM.loadedImages[imageURL] {
                    outfitImage.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                else {
                    ProgressView()
                        .frame(width: size.width, height: size.height)
                        .onAppear {
                            closetVM.loadImage(from: imageURL)
                        }
                }
            }
        }
    }
}
