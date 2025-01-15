import SwiftUI
import MapKit

class PreferencesViewModel: ObservableObject {
    @Published var selectedGenders: Set<Gender> = []
    @Published var allGendersSelected = true
    
    @Published var minAge: Int = 22
    @Published var maxAge: Int = 30
    
    @Published var location: CLLocationCoordinate2D? {
        didSet {
            if let location {
                setCityLocation(from: location)
            }
        }
    }
    @Published var cityLocation: String = ""
    
    var genderPreferenceText: String {
        if allGendersSelected {
            return "Everyone"
        }
        else {
            return selectedGenders.map { $0.type.preferenceDisplayName }.sorted().joined(separator: ", ")
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
    
    func setCityLocation(from location: CLLocationCoordinate2D) {
        location.getCityLocation { result in
            switch result {
            case .success(let locationString):
                self.cityLocation = locationString
            case .failure(let error):
                print("geocoding error: \(error)")
            }
        }
    }
}
