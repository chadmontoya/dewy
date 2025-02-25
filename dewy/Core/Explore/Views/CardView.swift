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
            if let imageURL = URL(string: outfit.imageURL!) {
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
                        Color.clear
                            .onAppear {
                                cardsVM.removeOutfitCard(model)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
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
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .offset(x: xOffset, y: yOffset)
        .rotationEffect(.degrees(degrees))
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
        
        if abs(width) <= abs(screenCutoff) {
            xOffset = 0
            degrees = 0
        }
        else if width >= screenCutoff {
            swipeRight()
        }
        else if width < screenCutoff {
            swipeLeft()
        }
        
        if abs(height) <= abs(screenCutoff) {
            yOffset = 0
            degrees = 0
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
        (UIScreen.main.bounds.width / 2) * 0.8
    }
    
    var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 20
    }
    
    var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 1.60
    }
}
