struct Gender: Codable, Equatable, Hashable {
    enum GenderType: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case nonBinary = "Non-Binary"
    }
    
    var type: GenderType
    
    init(type: GenderType) {
        self.type = type
    }
}
