import SwiftUI

struct RatingButtons: View {
    let userId: UUID
    let currentCard: OutfitCard?
    let cardsVM: CardsViewModel
    
    var body: some View {
        HStack(spacing: 30) {
            RatingButton(number: 1, color: Color(.systemRed).opacity(0.5)) {
                if let card = currentCard {
                    cardsVM.removeOutfitCard(card)
                    Task {
                        await cardsVM.rateOutfit(userId: userId, outfitId: card.outfit.id, rating: 1)
                    }
                }
            }
            
            RatingButton(number: 2, color: Color(.systemOrange).opacity(0.45)) {
                if let card = currentCard {
                    cardsVM.removeOutfitCard(card)
                    Task {
                        await cardsVM.rateOutfit(userId: userId, outfitId: card.outfit.id, rating: 2)
                    }
                }
            }
            
            RatingButton(number: 3, color: Color(.systemGreen).opacity(0.45)) {
                if let card = currentCard {
                    cardsVM.removeOutfitCard(card)
                    Task {
                        await cardsVM.rateOutfit(userId: userId, outfitId: card.outfit.id, rating: 3)
                    }
                }
            }
            
            RatingButton(number: 4, color: Color(.systemBlue).opacity(0.45)) {
                if let card = currentCard {
                    cardsVM.removeOutfitCard(card)
                    Task {
                        await cardsVM.rateOutfit(userId: userId, outfitId: card.outfit.id, rating: 4)
                    }
                }
            }
        }
        .padding(.vertical, 15)
    }
}

struct RatingButton: View {
    let number: Int
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            action()
        } label: {
            Text("\(number)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
    }
}
