struct Gender: Codable, Equatable, Hashable {
    enum GenderType: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case nonBinary = "Non-Binary"
        
        var preferenceDisplayName: String {
            switch self {
            case .male: return "Men"
            case .female: return "Women"
            case .nonBinary: return "Non-binary people"
            }
        }
    }
    
    var type: GenderType
    
    init(type: GenderType) {
        self.type = type
    }
}
