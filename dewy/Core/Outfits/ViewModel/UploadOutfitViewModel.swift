import SwiftUI
import CoreLocation
import PhotosUI

@MainActor
class UploadOutfitViewModel: ObservableObject {
    @Published var outfitImage: UIImage? = nil
    @Published var cameraImage: UIImage?
    @Published var selectedStyles: Set<Style> = []
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
    @Published var isNSFWContent: Bool = false
    
    private let outfitService: OutfitService
    private let styleService: StyleService
    private let preferencesService: PreferencesService
    private let storageService: StorageService
    
    init(
        outfitService: OutfitService,
        styleService: StyleService,
        preferencesService: PreferencesService
) {
        self.outfitService = outfitService
        self.styleService = styleService
        self.preferencesService = preferencesService
        self.storageService = StorageService(bucket: "outfits")
        
        Task { await fetchStyles() }
    }
    
    func fetchStyles() async {
        let styles: [Style] = await styleService.fetchStyles()
        await MainActor.run {
            self.availableStyles = styles
        }
    }
    
    func fetchLocation(userId: UUID) async {
        do {
            let fetchedLocation: CLLocationCoordinate2D = try await preferencesService.fetchProfileLocation(userId: userId)
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
    
    func saveOutfit(userId: UUID) async throws -> Outfit {
        guard let image = outfitImage else {
            throw UploadOutfitError.imageUploadFailed
        }
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            let analysis = try await ImageAnalysisService.shared.analyzeImage(image)
            print(analysis.isNsfw)
            if analysis.isNsfw {
                isNSFWContent = true
                throw ImageAnalysisError.nsfwContentDetected
            }
            let filePath = storageService.generateFilePath(userId: userId)
            let outfitImageUrl = try await storageService.uploadImage(image, path: filePath)
            
            let newOutfit = try await outfitService.createOutfit(userId: userId, imageUrl: outfitImageUrl, location: location!, locationString: cityLocation, isPublic: isPublic, selectedStyles: selectedStyles)
            
            return newOutfit
            
        } catch {
            print("unable to save outfit: \(error)")
            throw error
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

    func resetOutfitDetails() {
        selectedStyles = []
        isPublic = true
        location = nil
        cityLocation = ""
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    outfitImage = uiImage
                    unCroppedImageSelected = true
                    resetOutfitDetails()
                }
            }
        }
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
