import SwiftUI

struct OutfitDetailView: View {
    var outfit: Outfit
    var animation: Namespace.ID
    var selectedOutfitImage: Image?
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
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
                                .matchedGeometryEffect(id: outfit.id, in: animation)
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
        .ignoresSafeArea()
        .navigationTransition(.zoom(sourceID: outfit.id, in: animation))
    }
}
