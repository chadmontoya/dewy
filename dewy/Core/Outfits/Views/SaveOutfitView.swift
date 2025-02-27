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
                
                Form {
                    Section(header: Text("style").foregroundStyle(.black)) {
                        Button(action: {
                            showStyleTagSheet = true
                        }) {
                            HStack {
                                Image(systemName: "tag")
                                Text(uploadOutfitVM.selectedStyles.isEmpty ? "Select Tags" : uploadOutfitVM.selectedStyles.map { $0.name }.joined(separator: ", "))
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
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
                    
                    Section(header: Text("ratings").foregroundStyle(.black)) {
                        Button(action: {
                            showLocationSheet = true
                        }) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(uploadOutfitVM.cityLocation.isEmpty ? "Set Location" : uploadOutfitVM.cityLocation)
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "eye")
                                .foregroundStyle(.black)
                            Toggle("Make Public", isOn: $uploadOutfitVM.isPublic)
                        }
                    }
                    
                    Button {
                        Task {
                            do {
                                if let userId = authController.session?.user.id {
                                    let outfit = try await uploadOutfitVM.saveOutfit(userId: userId)
                                    outfitsVM.addOutfit(outfit: outfit)
                                    outfitsVM.showOutfitAddedToast = true
                                    outfitsVM.uploadOutfit = false
                                    onComplete()
                                }
                            }
                            catch {
                                print("error saving outfit: \(error)")
                            }
                        }
                    } label: {
                        Text("Add")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .background(.black)
                    }
                    .listRowInsets(EdgeInsets())
                    .cornerRadius(10)
                }
                .colorScheme(.light)
                .scrollContentBackground(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("new outfit")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
            }
            
            if uploadOutfitVM.isLoading {
                LoadingView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            Task {
                if let userId = authController.session?.user.id {
                    await uploadOutfitVM.fetchLocation(userId: userId)
                }
            }
        }
    }
}
