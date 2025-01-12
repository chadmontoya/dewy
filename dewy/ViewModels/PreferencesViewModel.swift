import SwiftUI

class PreferencesViewModel: ObservableObject {
    @Published var selectedGenders: Set<Gender> = [Gender(type: Gender.GenderType.male)]
    @Published var minAge: Int = 22
    @Published var maxAge: Int = 30
    @Published var allAgesSelected = false
    @Published var allGendersSelected = false
    
    var genderPreferenceText: String {
        if allGendersSelected {
            return "Everyone"
        }
        else {
            return selectedGenders.map { $0.type.rawValue }.sorted().joined(separator: ", ")
        }
    }
    
    var agePreferenceText: String {
        return "\(minAge)-\(maxAge)"
    }
    
    func updateAgePreference(minAge: Int, maxAge: Int) {
        self.minAge = minAge
        self.maxAge = maxAge
    }
    
    func toggleGender(_ genderType: Gender.GenderType) {
        allGendersSelected = false
        let gender = Gender(type: genderType)
        
        if selectedGenders.contains(gender) {
            if selectedGenders.count == 1 {
                selectAllGenders()
            }
            else {
                selectedGenders.remove(gender)
            }
        }
        else {
            allGendersSelected = false
            selectedGenders.insert(gender)
            
            if selectedGenders.count == Gender.GenderType.allCases.count {
                allGendersSelected = true
                selectedGenders.removeAll()
            }
        }
    }
    
    func selectAllGenders() {
        allGendersSelected = true
        selectedGenders.removeAll()
    }
}
