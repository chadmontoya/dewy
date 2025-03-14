import SwiftUI
import Shimmer

struct OutfitCardView: View {
    @EnvironmentObject var outfitsVM: OutfitsViewModel
    
    @State private var showDeleteConfirmation = false
    
    var screenSize: CGSize
    var outfit: Outfit
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            if let outfitImage = outfitsVM.loadedImages[outfit.imageURL] {
                outfitImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shimmering(
                        animation: .easeInOut(duration: 1)
                            .repeatForever(autoreverses: false)
                    )
                    .onAppear {
                        outfitsVM.loadImage(from: outfit.imageURL)
                    }
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                Task {
                    showDeleteConfirmation = true
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog("Delete Outfit", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await outfitsVM.deleteOutfit(outfitId: outfit.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this outfit?")
        }
    }
}
