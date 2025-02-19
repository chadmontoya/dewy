import SwiftUI

struct CollectionCard: View {
    var screenSize: CGSize
    var collection: Collection
    
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
                .frame(width: size.width * 0.5 - 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
