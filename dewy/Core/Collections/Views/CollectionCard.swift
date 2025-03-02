import SwiftUI
import Shimmer

struct CollectionCard: View {
    @EnvironmentObject var collectionsVM: CollectionsViewModel
    
    var screenSize: CGSize
    var collection: Collection
    
    private var isLoading: Bool {
        guard let urls = collection.thumbnailUrls else { return false }
        return !urls.allSatisfy { collectionsVM.loadedImages[$0] != nil }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            HStack(spacing: 4) {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: size.width * 0.5, height: size.height)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                    )
                    .overlay {
                        if !isLoading,
                           let firstImageURL = collection.thumbnailUrls?.first,
                           let firstImage = collectionsVM.loadedImages[firstImageURL] {
                            firstImage
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.clear.onAppear {
                                if let url = collection.thumbnailUrls?.first {
                                    collectionsVM.loadImage(from: url)
                                }
                            }
                        }
                    }
                    .clipped()
                
                VStack(spacing: 4) {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(height: (size.height - 4) / 2)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 12
                            )
                        )
                        .overlay {
                            if !isLoading,
                               let secondImageURL = collection.thumbnailUrls?.dropFirst().first,
                               let secondImage = collectionsVM.loadedImages[secondImageURL] {
                                secondImage
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color.clear.onAppear {
                                    if let url = collection.thumbnailUrls?.dropFirst().first {
                                        collectionsVM.loadImage(from: url)
                                    }
                                }
                            }
                        }
                        .clipped()
                    
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(height: (size.height - 4) / 2)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 12,
                                topTrailingRadius: 0
                            )
                        )
                        .overlay {
                            if !isLoading,
                               let thirdImageURL = collection.thumbnailUrls?.dropFirst(2).first,
                               let thirdImage = collectionsVM.loadedImages[thirdImageURL] {
                                thirdImage
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color.clear.onAppear {
                                    if let url = collection.thumbnailUrls?.dropFirst(2).first {
                                        collectionsVM.loadImage(from: url)
                                    }
                                }
                            }
                        }
                        .clipped()
                }
                .frame(width: size.width * 0.5 - 4)
            }
            .shimmering(
                active: isLoading,
                animation: .easeInOut(duration: 1)
                    .repeatForever(autoreverses: false)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
