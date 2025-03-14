import SwiftUI

struct OutfitImageView: View {
    let imageURL: String
    let outfitImage: Image?
    let geometry: GeometryProxy
    let onDismiss: () -> Void
    let loadImage: (String) -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if let outfitImage = outfitImage {
                outfitImage
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.85)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                DismissButton(action: onDismiss)
            } else {
                ProgressView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                    .onAppear {
                        loadImage(imageURL)
                    }
            }
        }
    }
}

struct DismissButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .foregroundStyle(.black)
                .padding()
                .background(Circle().fill(Color.white))
                .shadow(radius: 5)
        }
        .padding()
    }
}

struct StyleTagsSection: View {
    let styleIds: [Int64]
    let availableStyles: [Style]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(styleIds, id: \.self) { styleId in
                        if let style = availableStyles.first(where: {$0.id == styleId}) {
                            StyleTag(name: style.name)
                        }
                    }
                }
            }
        }
    }
}

struct StyleTag: View {
    let name: String
    
    var body: some View {
        Text(name)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.2)))
            .foregroundStyle(.black)
    }
}

struct OutfitDetailView: View {
    var outfit: Outfit
    var animation: Namespace.ID
    @EnvironmentObject var outfitsVM: OutfitsViewModel
    @Environment(\.dismiss) private var dismissView
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    OutfitImageView(
                        imageURL: outfit.imageURL,
                        outfitImage: outfitsVM.loadedImages[outfit.imageURL],
                        geometry: geometry,
                        onDismiss: { dismissView() },
                        loadImage: outfitsVM.loadImage
                    )
                    
                    StyleTagsSection(
                        styleIds: outfit.styleIds,
                        availableStyles: outfitsVM.availableStyles
                    )
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(Color.black)
                            Text(outfit.locationString)
                                .font(.subheadline)
                                .foregroundStyle(Color.black)
                            
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding()
        .background(Color.primaryBackground)
        .navigationTransition(.zoom(sourceID: outfit.id, in: animation))
    }
}
