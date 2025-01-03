import SwiftUI

struct OutfitDetailView: View {
    var outfit: Outfit
    var animation: Namespace.ID
    @ObservedObject var closetVM: ClosetViewModel
    @Environment(\.dismiss) private var dismissView
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                ZStack(alignment: .topLeading) {
                    if let imageURL = outfit.imageURL {
                        if let outfitImage = closetVM.loadedImages[imageURL] {
                            outfitImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 650)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                            Button(action: {
                                dismissView()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.black)
                                    .padding()
                                    .background(Circle().fill(Color.white))
                                    .shadow(radius: 5)
                            }
                            .padding()
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
        .padding()
        .background(Color.cream)
        .navigationTransition(.zoom(sourceID: outfit.id, in: animation))
    }
}
