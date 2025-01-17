import SwiftUI

struct CardView: View {
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    
    let imageURL = "https://riycadlhyixpkdpvxhpx.supabase.co/storage/v1/object/public/outfits/5623D9D6-868A-42E7-8DE7-A12F81E2E333/5EAF2AB7-791D-4EEA-AADC-CB6FB56FD45D-1736462983.jpg"
    
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
        .animation(.snappy, value: yOffset)
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }
}

private extension CardView {
    func swipeRight() {
        xOffset = 500
    }
    
    func swipeUp() {
        yOffset = 1000
    }
    
    func swipeDown() {
        yOffset = -1000
    }
    
    func swipeLeft() {
        xOffset = -500
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
        else if width >= screenCutoff {
            swipeRight()
        }
        else if width < screenCutoff {
            swipeLeft()
        }
        
        if abs(height) <= abs(screenCutoff) {
            yOffset = 0
        }
        else if height >= screenCutoff {
            swipeUp()
        }
        else if height < screenCutoff {
            swipeDown()
        }
    }
}

private extension CardView {
    var screenCutoff: CGFloat {
        (UIScreen.main.bounds.width / 2) * 0.5
    }
    
    var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 20
    }
    
    var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 1.45
    }
}
