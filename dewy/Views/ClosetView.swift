import SwiftUI

struct ClosetView: View {
    @Binding var uploadOutfit: Bool
    
    @EnvironmentObject var authController: AuthController
    
    @StateObject private var closetVM: ClosetViewModel = ClosetViewModel()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            
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
                
                outfitList
            }
            .padding()
        }
        .onAppear {
            Task {
                try await closetVM.fetchOutfits(userId: authController.currentUserId)
            }
        }
    }
    
    var outfitList: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(closetVM.outfits) { outfit in
                    AsyncImage(url: URL(string: outfit.imageURL!)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 200)
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            Image(systemName: "photo")
                                .frame(width: 120, height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}
