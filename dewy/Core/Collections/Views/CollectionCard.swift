import SwiftUI
import Shimmer

struct CollectionCard: View {
    @EnvironmentObject var collectionsVM: CollectionsViewModel
    
    var screenSize: CGSize
    var collection: Collection
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            HStack(spacing: 4) {
                if let firstImageURL = collection.thumbnailUrls?.first {
                    if let firstImage = collectionsVM.loadedImages[firstImageURL] {
                        firstImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width * 0.5, height: size.height)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 12,
                                    bottomLeadingRadius: 12,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: 0
                                )
                            )
                    } else {
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
                            .shimmering(
                                animation: .easeInOut(duration: 1)
                                    .repeatForever(autoreverses: false)
                            )
                            .onAppear {
                                //                                collectionsVM.loadImage(from: firstImageURL)
                            }
                    }
                }
                else {
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
                }
                
                VStack(spacing: 4) {
                    if let secondImageURL = collection.thumbnailUrls?.dropFirst().first {
                        if let secondImage = collectionsVM.loadedImages[secondImageURL] {
                            secondImage
                                .resizable()
                                .scaledToFill()
                                .frame(height: (size.height - 4) / 2)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 12
                                    )
                                )
                        } else {
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
                                .shimmering(
                                    animation: .easeInOut(duration: 1)
                                        .repeatForever(autoreverses: false)
                                )
                                .onAppear {
                                    //                                    collectionsVM.loadImage(from: secondImageURL)
                                }
                        }
                    } else {
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
                    }
                    
                    if let thirdImageURL = collection.thumbnailUrls?.dropFirst(2).first {
                        if let thirdImage = collectionsVM.loadedImages[thirdImageURL] {
                            thirdImage
                                .resizable()
                                .scaledToFill()
                                .frame(height: (size.height - 4) / 2)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 12,
                                        topTrailingRadius: 0
                                    )
                                )
                        } else {
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
                                .shimmering(
                                    animation: .easeInOut(duration: 1)
                                        .repeatForever(autoreverses: false)
                                )
                                .onAppear {
                                    //                                    collectionsVM.loadImage(from: thirdImageURL)
                                }
                        }
                    } else {
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
                    }
                }
                .frame(width: size.width * 0.5 - 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
