import SwiftUI
import PhotosUI

struct CropperView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width * 2.5) // 1:2.5 aspect ratio for outfits
                        .clipped()
                        .overlay(
                            Rectangle()
                                .stroke(.white, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Crop Photo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // Pass the cropped image
                        onCrop(image)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CustomPhotoPicker: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showingCropper = false
    @State private var currentImageToCrop: UIImage?
    @State private var currentCropIndex: Int?
    
    var body: some View {
        VStack {
            if !selectedImages.isEmpty {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    Button(action: {
                                        selectedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .background(Circle().fill(.black))
                                    }
                                    .padding(4),
                                    alignment: .topTrailing
                                )
                                .overlay(
                                    Button(action: {
                                        currentImageToCrop = selectedImages[index]
                                        currentCropIndex = index
                                        showingCropper = true
                                    }) {
                                        Image(systemName: "crop")
                                            .foregroundStyle(.white)
                                            .padding(4)
                                            .background(Circle().fill(.black))
                                    }
                                    .padding(4),
                                    alignment: .bottomTrailing
                                )
                        }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView("No Photos Selected",
                    systemImage: "photo.badge.plus",
                    description: Text("Tap the button below to select photos"))
            }
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Select outfit photos", systemImage: "photo.on.rectangle.angled")
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            if !selectedImages.isEmpty {
                Text("\(selectedImages.count)/10 photos selected")
                    .foregroundStyle(.secondary)
                    .padding(.top, 5)
            }
        }
        .onChange(of: selectedItems) {
            Task {
                selectedImages.removeAll()
                
                for item in selectedItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImages.append(uiImage)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCropper) {
            if let image = currentImageToCrop {
                CropperView(image: image) { croppedImage in
                    if let index = currentCropIndex {
                        selectedImages[index] = croppedImage
                    }
                }
            }
        }
    }
}

#Preview {
    CustomPhotoPicker()
}

