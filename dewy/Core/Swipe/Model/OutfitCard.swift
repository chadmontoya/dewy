import Foundation

struct OutfitCard {
    let outfit: Outfit
}

extension OutfitCard: Identifiable, Hashable {
    var id: Int64 { return outfit.id }
}
