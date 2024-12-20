import SwiftUI
import MapKit
import PhotosUI

@MainActor
class UploadOutfitViewModel: ObservableObject {
    @Published var outfitImage: UIImage? = nil
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
    
    func setCroppedImage(_ croppedImage: UIImage) {
        outfitImage = croppedImage
        croppedImageSelected = true
        imageSelection = nil
    }
    
    func uploadOutfitImage(userId: UUID) async -> String? {
        guard let image = outfitImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("unable to get image data")
            return nil
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
            print("error uploading image to bucket: \(error)")
            return nil
        }
    }
    
    func saveOutfit(userId: UUID) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            guard let outfitImageURL = await uploadOutfitImage(userId: userId) else {
                print("failed to upload image")
                return
            }
            
            let outfit: Outfit = Outfit(
                userId: userId,
                imageURL: outfitImageURL,
                location: location,
                isPublic: isPublic
            )
            
            try await supabase
                .from("Outfits")
                .insert(outfit)
                .execute()
            
            isComplete = true
        }
        catch {
            print("error saving outfit to database: \(error)")
        }
        
        isLoading = false
    }

    func setCityLocation(from location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("geocoding error: \(error)")
                return
            }
            
            if let placemark = placemarks?.first {
                var locationString = ""
                
                if let city = placemark.locality {
                    locationString = city
                }
                
                if let state = placemark.administrativeArea {
                    locationString += locationString.isEmpty ? state : ", \(state)"
                }
                
                if let country = placemark.country {
                    locationString += locationString.isEmpty ? country : ", \(country)"
                }
                
                self.cityLocation = locationString
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
