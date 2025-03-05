import SwiftUI

struct SaveOutfitView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var uploadOutfitVM: UploadOutfitViewModel
    @EnvironmentObject var outfitsVM: OutfitsViewModel
    
    @State private var showStyleTagSheet: Bool = false
    @State private var showLocationSheet: Bool = false
    
    private let screenHeight = UIScreen.main.bounds.height
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.primaryBackground.ignoresSafeArea()
            
            VStack {
                HStack {
                    if let selectedImage = uploadOutfitVM.outfitImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: screenHeight * 0.45)
                            .clipShape((RoundedRectangle(cornerRadius: 10)))
                    }
                }
                .frame(maxWidth: .infinity)
                
                OutfitDetailsForm(
                    showStyleTagSheet: $showStyleTagSheet,
                    showLocationSheet: $showLocationSheet,
                    uploadOutfitVM: uploadOutfitVM,
                    onSave: saveOutfit
                )
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("new outfit")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
            }
            .toolbar(uploadOutfitVM.isLoading ? .hidden : .visible)
            .onAppear {
                Task {
                    if let userId = authController.session?.user.id {
                        await uploadOutfitVM.fetchLocation(userId: userId)
                    }
                }
            }
            .alert(
                "Inappropriate Content",
                isPresented: $uploadOutfitVM.isNSFWContent,
                actions: {
                    Button("OK", role: .cancel) {
                        uploadOutfitVM.isNSFWContent = false
                    }
                },
                message: {
                    Text("this image contains inappropriate content and cannot be uploaded")
                }
            )
            
            if uploadOutfitVM.isLoading {
                LoadingView()
                    .transition(.opacity)
            }
        }
    }
    
    private func saveOutfit() {
        Task {
            do {
                if let userId = authController.session?.user.id {
                    let outfit = try await uploadOutfitVM.saveOutfit(userId: userId)
                    outfitsVM.addOutfit(outfit: outfit)
                    uploadOutfitVM.isLoading = true
                    outfitsVM.showOutfitAddedToast = true
                    outfitsVM.uploadOutfit = false
                    onComplete()
                }
            } catch {
                print("error saving outfit: \(error)")
            }
        }
    }
}

struct OutfitDetailsForm: View {
    @Binding var showStyleTagSheet: Bool
    @Binding var showLocationSheet: Bool
    @ObservedObject var uploadOutfitVM: UploadOutfitViewModel
    let onSave: () -> Void
    
    var body: some View {
        Form {
            Section(header: Text("style").foregroundStyle(.black)) {
                Button(action: { showStyleTagSheet = true }) {
                    HStack {
                        Image(systemName: "tag")
                        Text(uploadOutfitVM.selectedStyles.isEmpty ? "Select Tags" : uploadOutfitVM.selectedStyles.map { $0.name }.joined(separator: ", "))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            Section(header: Text("ratings").foregroundStyle(.black)) {
                Button(action: { showLocationSheet = true }) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(uploadOutfitVM.cityLocation.isEmpty ? "Set Location" : uploadOutfitVM.cityLocation)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                
                HStack {
                    Image(systemName: "eye")
                        .foregroundStyle(.black)
                    Toggle("Make Public", isOn: $uploadOutfitVM.isPublic)
                }
            }
            
            Button(action: onSave) {
                Text("Add")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(.black)
            }
            .listRowInsets(EdgeInsets())
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .colorScheme(.light)
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showStyleTagSheet) {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()
                StyleTagView(showStyleTagSheet: $showStyleTagSheet)
                    .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showLocationSheet) {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()
                OutfitLocationView(showLocationSheet: $showLocationSheet)
            }
        }
    }
}
