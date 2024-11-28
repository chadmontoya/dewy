import SwiftUI

struct UploadOutfitWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // You can update the view controller if needed
    }
}

