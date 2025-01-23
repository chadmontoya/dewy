import SwiftUI
import CoreLocation

@MainActor
class PreferencesViewModel: ObservableObject {
    @Published var selectedGenders: Set<Gender> = []
    @Published var allGendersSelected = false
    @Published var minAge: Int = 18
    @Published var maxAge: Int = 19
    @Published var availableStyles: [Style] = []
    @Published var selectedStyles: [Int64: String] = [:]
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
    
    var stylePreferenceText: String {
        return ""
    }
    
    private let preferencesService: PreferencesService
    private let styleService: StyleService
    
    init(preferencesService: PreferencesService, styleService: StyleService) {
        self.preferencesService = preferencesService
        self.styleService = styleService
        
        Task {
            try await fetchStyles()
        }
    }
    
    func fetchPreferences(userId: UUID) async throws {
        do {
            let preferences: Preferences = try await preferencesService.fetchPreferences(userId: userId)
            updatePreferences(from: preferences)
        }
        catch {
            print("failed to fetch preferences: \(error)")
        }
    }
    
    func fetchStyles() async throws {
        do {
            self.availableStyles = try await styleService.fetchStyles()
        }
        catch {
            print("failed to fetch styles: \(error)")
        }
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
    
    private func updatePreferences(from preferences: Preferences) {
        if preferences.preferredGenders.count == Gender.GenderType.allCases.count {
            allGendersSelected = true
            selectedGenders.removeAll()
        }
        else {
            allGendersSelected = false
            selectedGenders = Set(preferences.preferredGenders.map(Gender.init))
        }
        
        minAge = preferences.minAge
        maxAge = preferences.maxAge
        location = preferences.location
    }
}
