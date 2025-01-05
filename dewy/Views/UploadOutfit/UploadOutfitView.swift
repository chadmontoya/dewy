import SwiftUI
import SwiftyCrop

struct UploadOutfitView: View {
    @EnvironmentObject var authController: AuthController
    
    @StateObject private var uploadOutfitVM: UploadOutfitViewModel = UploadOutfitViewModel()
    
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.softBeige.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Button(action: {
                    // TODO: implement camera functionality
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
                    .background(Color.chocolate)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                Button(action: {
                    uploadOutfitVM.showImagePicker = true
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
                    .background(Color.chocolate)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .photosPicker(isPresented: $uploadOutfitVM.showImagePicker, selection: $uploadOutfitVM.imageSelection, matching: .images)
        .fullScreenCover(isPresented: $uploadOutfitVM.unCroppedImageSelected) {
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
        interactionInstructions: Color.coffee,
        saveButton: Color.black,
        background: Color.lightSand
    )
)
