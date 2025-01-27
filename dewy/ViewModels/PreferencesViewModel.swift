import SwiftUI
import CoreLocation

@MainActor
class PreferencesViewModel: ObservableObject {
    var preferencesId: Int64?
    @Published var selectedGenders: Set<Gender> = []
    @Published var allGendersSelected = false
    @Published var minAge: Int = 18
    @Published var maxAge: Int = 19
    @Published var availableStyles: [Style] = []
    @Published var selectedStyles: Set<Style> = []
    @Published var allStylesSelected: Bool = false
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
        if allStylesSelected {
            return "All"
        }
        else {
            return selectedStyles.isEmpty ? "Select styles" : selectedStyles.map(\.name).sorted().joined(separator: ", ")
        }
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
            
            setPreferences(from: preferences)
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
    
    func savePreferences(userId: UUID) async throws {
        var genderPreferences: [Gender.GenderType] = Gender.GenderType.allCases
        if !allGendersSelected {
            genderPreferences = selectedGenders.map(\.type)
        }
        
        do {
            if let preferencesId {
                try await preferencesService.updatePreferences(id: preferencesId, userId: userId, minAge: minAge, maxAge: maxAge, preferredGenders: genderPreferences, location: location!, selectedStyles: selectedStyles, allStylesPreferred: allStylesSelected)
            }
        }
        catch {
            print("error saving preferences: \(error)")
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
    
    func toggleStyle(_ style: Style) {
        if selectedStyles.contains(style) && selectedStyles.count > 1 {
            selectedStyles.remove(style)
            allStylesSelected = false
        }
        else {
            selectedStyles.insert(style)
            if selectedStyles.count == availableStyles.count {
                allStylesSelected = true
            }
        }
    }
    
    func selectAllGenders() {
        allGendersSelected = true
        selectedGenders.removeAll()
    }
    
    func selectAllStyles() {
        if allStylesSelected {
            selectedStyles.removeAll()
            selectedStyles.insert(availableStyles.first!)
            allStylesSelected = false
        }
        else {
            selectedStyles = Set(availableStyles)
            allStylesSelected = true
        }
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
    
    func setPreferences(from preferences: Preferences) {
        preferencesId = preferences.id
        
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
        allStylesSelected = preferences.allStylesPreferred
        
        setSelectedStyles(from: preferences.selectedStyleIds!)
    }
    
    private func setSelectedStyles(from styleIds: [Int64]) {
        selectedStyles = Set(availableStyles.filter { styleIds.contains($0.id) })
    }
}
