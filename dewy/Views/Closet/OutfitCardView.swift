import SwiftUI

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
