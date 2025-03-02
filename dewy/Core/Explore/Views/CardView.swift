import SwiftUI

struct CardView: View {
    @ObservedObject var cardsVM: CardsViewModel
    @ObservedObject var collectionsVM: CollectionsViewModel
    
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var degrees: Double = 0
    
    let userId: UUID
    let model: OutfitCard
    
    var body: some View {
        ZStack {
            if let imageURL = model.outfit.imageURL,
               let preloadedImage = cardsVM.preloadedImages[imageURL] {
                Image(uiImage: preloadedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .contextMenu {
                        Button {
                            collectionsVM.newCollectionOutfitId = model.id
                            collectionsVM.newCollectionOutfitImageUrl = model.outfit.imageURL!
                            collectionsVM.saveToCollection = true
                        } label: {
                            Label("Save", systemImage: "bookmark")
                        }
                        
                        Button {
                            cardsVM.removeOutfitCard(model)
                            Task {
                                await cardsVM.rateOutfit(userId: userId, outfitId: model.outfit.id, rating: 0)
                            }
                        } label: {
                            Label("Skip", systemImage: "arrow.uturn.right")
                        }
                        
                        Button(role: .destructive) {
                            print("reporting outfit: \(model.id)")
                        } label: {
                            Label("Report", systemImage: "flag")
                        }
                    }
                RatingActionIndicator(xOffset: $xOffset, yOffset: $yOffset, screenCutoff: screenCutoff)
            } else {
                Color.clear
                    .onAppear {
                        cardsVM.removeOutfitCard(model)
                    }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .offset(x: xOffset, y: yOffset)
        .rotationEffect(.degrees(degrees))
        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5), value: [xOffset, yOffset])
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }
}

struct ShimmerCardView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.gray.opacity(0.4))
            .frame(
                width: UIScreen.main.bounds.width - 15,
                height: UIScreen.main.bounds.height / 1.50
            )
            .shimmering(
                animation: .easeInOut(duration: 1)
                    .repeatForever(autoreverses: false)
            )
    }
}

private extension CardView {
    var outfit: Outfit {
        return model.outfit
    }
}

private extension CardView {
    func animateSwipe(xOffset: CGFloat = 0, yOffset: CGFloat = 0, degrees: Double = 0) {
        withAnimation {
            self.xOffset = xOffset
            self.yOffset = yOffset
            self.degrees = degrees
        } completion: {
            cardsVM.removeOutfitCard(model)
        }
    }
    func swipeRight() {
        withAnimation {
            xOffset = 500
            yOffset = 0
            degrees = 12
        } completion: {
            cardsVM.removeOutfitCard(model)
            Task {
                await cardsVM.rateOutfit(userId: userId, outfitId: model.outfit.id, rating: 3)
            }
        }
    }
    
    func swipeUp() {
        withAnimation {
            yOffset = 1000
            xOffset = 0
            degrees = 0
        } completion: {
            cardsVM.removeOutfitCard(model)
            Task {
                await cardsVM.rateOutfit(userId: userId, outfitId: model.outfit.id, rating: 1)
            }
        }
    }
    
    func swipeDown() {
        withAnimation {
            yOffset = -1000
            xOffset = 0
            degrees = 0
        } completion: {
            cardsVM.removeOutfitCard(model)
            Task {
                await cardsVM.rateOutfit(userId: userId, outfitId: model.outfit.id, rating: 4)
            }
        }
    }
    
    func swipeLeft() {
        withAnimation {
            xOffset = -500
            yOffset = 0
            degrees = -12
        } completion: {
            cardsVM.removeOutfitCard(model)
            Task {
                await cardsVM.rateOutfit(userId: userId, outfitId: model.outfit.id, rating: 2)
            }
        }
    }
}

private extension CardView {
    func onDragChanged(_ value: _ChangedGesture<DragGesture>.Value) {
        xOffset = value.translation.width
        yOffset = value.translation.height
        degrees = Double(value.translation.width / 25)
    }
    
    func onDragEnded(_ value: _ChangedGesture<DragGesture>.Value) {
        let width = value.translation.width
        let height = value.translation.height
        
        if abs(width) <= abs(screenCutoff) && abs(height) <= abs(screenCutoff) {
            withAnimation(.easeInOut) {
                xOffset = 0
                yOffset = 0
                degrees = 0
            }
            return
        }
        
        if abs(width) > abs(height) {
            if width > 0 {
                swipeRight()
            } else {
                swipeLeft()
            }
        } else {
            if height > 0 {
                swipeUp()
            } else {
                swipeDown()
            }
        }
    }
}

private extension CardView {
    var screenCutoff: CGFloat {
        (UIScreen.main.bounds.width / 2) * 0.8
    }
    
    var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 15
    }
    
    var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 1.50
    }
}
