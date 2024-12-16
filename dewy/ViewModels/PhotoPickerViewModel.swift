import PhotosUI
import SwiftUI
import SwiftyCrop

@MainActor
class PhotoPickerViewModel: ObservableObject {
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    @Published var imageSelected: Bool = false
    @Published var croppedImageSelected: Bool = false
    @Published var showPicker: Bool = false
    
    func setCroppedImage(_ croppedImage: UIImage) {
        selectedImage = croppedImage
        croppedImageSelected = true
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    imageSelected = true
                    return
                }
            }
        }
    }
}
