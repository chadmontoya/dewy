import SwiftUI
import Shimmer

struct CollectionCard: View {
    @EnvironmentObject var collectionsVM: CollectionsViewModel
    
    var screenSize: CGSize
    var collection: Collection
    
    private var isLoading: Bool {
        return !collection.thumbnailUrls.allSatisfy { collectionsVM.loadedImages[$0] != nil }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            HStack(spacing: 4) {
                Group {
                    if !isLoading,
                       let firstImageUrl = collection.thumbnailUrls.first,
                       let firstImage = collectionsVM.loadedImages[firstImageUrl] {
                        firstImage
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .onAppear {
                                if let url = collection.thumbnailUrls.first {
                                    collectionsVM.loadImage(from: url)
                                }
                            }
                    }
                }
                .frame(width: size.width * 0.5, height: size.height)
                .clipShape(
                    .rect(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                )
                
                VStack(spacing: 4) {
                    Group {
                        if !isLoading,
                           let secondImageUrl = collection.thumbnailUrls.dropFirst().first,
                           let secondImage = collectionsVM.loadedImages[secondImageUrl] {
                            secondImage
                                .resizable()
                                .scaledToFill()
                        } else {
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                                .onAppear {
                                    if let url = collection.thumbnailUrls.dropFirst().first {
                                        collectionsVM.loadImage(from: url)
                                    }
                                }
                        }
                    }
                    .frame(height: (size.height - 4) / 2)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 12
                        )
                    )
                    
                    Group {
                        if !isLoading,
                           let thirdImageURL = collection.thumbnailUrls.dropFirst(2).first,
                           let thirdImage = collectionsVM.loadedImages[thirdImageURL] {
                            thirdImage
                                .resizable()
                                .scaledToFill()
                        } else {
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                                .onAppear {
                                    if let url = collection.thumbnailUrls.dropFirst(2).first {
                                        collectionsVM.loadImage(from: url)
                                    }
                                }
                        }
                    }
                    .frame(height: (size.height - 4) / 2)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 12,
                            topTrailingRadius: 0
                        )
                    )
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
