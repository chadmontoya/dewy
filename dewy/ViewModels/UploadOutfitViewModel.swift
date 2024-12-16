import SwiftUI
import MapKit
import PhotosUI

@MainActor
class UploadOutfitViewModel: ObservableObject {
    @Published var outfitImage: UIImage? = nil
    @Published var styleTags: Set<String> = []
    @Published var location: CLLocationCoordinate2D?
    @Published var description: String = ""
    @Published var isPublic: Bool = true
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    @Published var imageSelected: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var croppedImageSelected: Bool = false
    
    func setCroppedImage(_ croppedImage: UIImage) {
        outfitImage = croppedImage
        croppedImageSelected = true
        imageSelection = nil
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    outfitImage = uiImage
                    imageSelected = true
                    return
                }
            }
        }
    }
}
