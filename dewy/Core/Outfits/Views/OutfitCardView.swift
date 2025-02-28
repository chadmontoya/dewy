import SwiftUI

struct OutfitCardView: View {
    
    @State private var showDeleteConfirmation = false
    
    var screenSize: CGSize
    var outfit: Outfit
    
    @EnvironmentObject var outfitsVM: OutfitsViewModel
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            if let imageURL = outfit.imageURL {
                if let outfitImage = outfitsVM.loadedImages[imageURL] {
                    outfitImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                else {
                    ProgressView()
                        .frame(width: size.width, height: size.height)
                        .onAppear {
                            outfitsVM.loadImage(from: imageURL)
                        }
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
                    outfitsVM.showOutfitDeletedToast = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this outfit?")
        }
    }
}
