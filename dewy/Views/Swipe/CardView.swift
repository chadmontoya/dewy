import SwiftUI

struct CardView: View {
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    
    let imageURL = "https://riycadlhyixpkdpvxhpx.supabase.co/storage/v1/object/public/outfits/5623D9D6-868A-42E7-8DE7-A12F81E2E333/F875DDB8-9494-48E5-B5B9-6F24DAE2E903-1736220057.jpg"
    
    var body: some View {
        ZStack {
            if let imageURL = URL(string: imageURL) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: cardWidth, height: cardHeight)
                    case.success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: cardHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    case .failure:
                        Text("something went wrong")
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .offset(x: xOffset, y: yOffset)
        .animation(.snappy, value: xOffset)
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }
}

private extension CardView {
    func onDragChanged(_ value: _ChangedGesture<DragGesture>.Value) {
        xOffset = value.translation.width
        yOffset = value.translation.height
        
    }
    
    func onDragEnded(_ value: _ChangedGesture<DragGesture>.Value) {
        let width = value.translation.width
        let height = value.translation.height
        
        if abs(width) <= abs(screenCutoff) {
            xOffset = 0
        }
        
        if abs(height) <= abs(screenCutoff) {
            yOffset = 0
        }
    }
}

private extension CardView {
    var screenCutoff: CGFloat {
        (UIScreen.main.bounds.width / 2) * 0.8
    }
    
    var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 20
    }
    
    var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 1.45
    }
}
