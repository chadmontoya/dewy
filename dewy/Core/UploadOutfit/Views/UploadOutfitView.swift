import SwiftUI
import SwiftyCrop

struct UploadOutfitView: View {
    @EnvironmentObject var authController: AuthController
    
    @StateObject var uploadOutfitVM: UploadOutfitViewModel = UploadOutfitViewModel(
        outfitService: OutfitService(),
        styleService: StyleService(),
        preferencesService: PreferencesService()
    )
    
    @State private var showCamera = false
    @State private var showImagePicker = false
    @State private var cameraError: CameraPermission.CameraError?
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Button(action: {
                    if let error = CameraPermission.checkPermissions() {
                        cameraError = error
                    } else {
                        showCamera = true
                    }
                }) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("snap from")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("camera")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .bold()
                        }
                        Spacer()
                        Image(systemName: "camera")
                            .bold()
                        Spacer()
                    }
                    .frame(maxWidth: 300)
                    .padding()
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .alert(isPresented: .constant(cameraError != nil), error: cameraError) { _ in
                        Button("OK") {
                            cameraError = nil
                        }
                    } message: { error in
                        Text(error.recoverySuggestion ?? "Try again later")
                    }
                    .sheet(isPresented: $showCamera) {
                        UIKitCamera(uploadOutfitVM: uploadOutfitVM)
                            .ignoresSafeArea()
                    }
                }
                
                Button(action: {
                    showImagePicker = true
                }) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("upload from")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("photo gallery")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .bold()
                        }
                        Spacer()
                        Image(systemName: "photo.on.rectangle")
                            .bold()
                        Spacer()
                    }
                    .frame(maxWidth: 300)
                    .padding()
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $uploadOutfitVM.imageSelection, matching: .images)
        .sheet(isPresented: $uploadOutfitVM.unCroppedImageSelected) {
            if let outfitImage = uploadOutfitVM.outfitImage {
                SwiftyCropView(
                    imageToCrop: outfitImage,
                    maskShape: .rectangle,
                    configuration: configuration
                ) { croppedImage in
                    guard let croppedImage else {
                        print("no cropped image")
                        return
                    }
                    uploadOutfitVM.setCroppedImage(croppedImage)
                }
            }
        }
        .navigationDestination(isPresented: $uploadOutfitVM.croppedImageSelected) {
            OutfitDetailsView(onComplete: onComplete)
                .environmentObject(uploadOutfitVM)
                .toolbarRole(.editor)
        }
    }
}

let configuration = SwiftyCropConfiguration(
    maxMagnificationScale: 4.0,
    maskRadius: 300,
    cropImageCircular: false,
    rotateImage: false,
    zoomSensitivity: 4.0,
    rectAspectRatio: 9/16,
    texts: SwiftyCropConfiguration.Texts(
        saveButton: "Crop"
    ),
    colors: SwiftyCropConfiguration.Colors(
        cancelButton: Color.black,
        interactionInstructions: Color.black,
        saveButton: Color.black,
        background: Color.cream
    )
)
