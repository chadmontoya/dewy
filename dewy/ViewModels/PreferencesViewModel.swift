import SwiftUI

class PreferencesViewModel: ObservableObject {
    @Published var selectedGenders: Set<Gender> = [Gender(type: Gender.GenderType.male)]
    @Published var allGendersSelected = false
    
    var genderPreferenceText: String {
        if allGendersSelected {
            return "Everyone"
        }
        else {
            return selectedGenders.map { $0.type.rawValue }.sorted().joined(separator: ", ")
        }
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
