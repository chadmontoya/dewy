import SwiftUI
import CoreLocation
import PhotosUI

@MainActor
class UploadOutfitViewModel: ObservableObject {
    @Published var outfitImage: UIImage? = nil
    @Published var selectedStyles: [Int64: String] = [:]
    @Published var availableStyles: [Style] = []
    @Published var styleTags: Set<String> = []
    @Published var location: CLLocationCoordinate2D? {
        didSet {
            if let location = location {
                setCityLocation(from: location)
            }
        }
    }
    @Published var cityLocation: String = ""
    @Published var isPublic: Bool = true
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    @Published var showImagePicker: Bool = false
    @Published var unCroppedImageSelected: Bool = false
    @Published var croppedImageSelected: Bool = false
    @Published var isLoading: Bool = false
    @Published var isComplete: Bool = false
    
    private let styleService: StyleService
    private let preferencesService: PreferencesService
    
    init(styleService: StyleService, preferencesService: PreferencesService) {
        self.styleService = styleService
        self.preferencesService = preferencesService
    }
    
    func fetchStyles() async throws {
        do {
            self.availableStyles = try await styleService.fetchStyles()
        }
        catch {
            print("failed to fetch styles: \(error))")
        }
    }
    
    func fetchLocation(userId: UUID) async throws {
        do {
            let fetchedLocation: CLLocationCoordinate2D = try await preferencesService.fetchLocation(userId: userId)
            self.location = fetchedLocation
            setCityLocation(from: fetchedLocation)
        }
        catch {
            print("failed to fetch location: \(error)")
        }
    }
    
    func setCroppedImage(_ croppedImage: UIImage) {
        outfitImage = croppedImage
        croppedImageSelected = true
        imageSelection = nil
    }
    
    func uploadOutfitImage(userId: UUID) async throws -> String? {
        guard let image = outfitImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw UploadOutfitError.imageUploadFailed
        }
        
        let filename = generateRandomFilename()
        let filePath = "\(userId)/\(filename)"
        
        do {
            try await supabase.storage
                .from("outfits")
                .upload(
                    filePath,
                    data: imageData
                )
            
            let publicURL: URL = try supabase.storage
                .from("outfits")
                .getPublicURL(path: filePath)
            
            return publicURL.absoluteString
        }
        catch {
            throw UploadOutfitError.imageUploadFailed
        }
    }
    
    func saveOutfit(userId: UUID) async throws -> Outfit {
        guard !isLoading else { throw UploadOutfitError.alreadyLoading }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            let outfitImageURL = try await uploadOutfitImage(userId: userId)
            
            let outfit: Outfit = try await supabase
                .from("Outfits")
                .insert(Outfit(userId: userId, imageURL: outfitImageURL, location: location, isPublic: isPublic))
                .select()
                .single()
                .execute()
                .value
            
            try await saveOutfitStyles(outfitId: outfit.id)
            
            isComplete = true
            return outfit
        }
        catch {
            throw UploadOutfitError.outfitSaveFailed
        }
    }
    
    func saveOutfitStyles(outfitId: Int64) async throws {
        let outfitStyles = selectedStyles.map { (styleId, styleName) in
            OutfitStyle(outfitId: outfitId, styleId: styleId)
        }
        
        try await supabase
            .from("Outfit_Styles")
            .insert(outfitStyles)
            .execute()
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
    
    private func generateRandomFilename() -> String {
        let uuid = UUID().uuidString
        let timestamp = Int(Date().timeIntervalSince1970)
        
        return "\(uuid)-\(timestamp).jpg"
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    outfitImage = uiImage
                    unCroppedImageSelected = true
                    resetOutfitDetails()
                    return
                }
            }
        }
    }
    
    private func resetOutfitDetails() {
        styleTags = []
        isPublic = true
        location = nil
        cityLocation = ""
    }
}

enum UploadOutfitError: Error {
    case alreadyLoading
    case imageUploadFailed
    case outfitSaveFailed
}

struct LocationResponse: Decodable {
    let lat: Double
    let long: Double
}
