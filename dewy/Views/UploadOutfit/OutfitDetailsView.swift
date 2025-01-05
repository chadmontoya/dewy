import SwiftUI

struct OutfitDetailsView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var uploadOutfitVM: UploadOutfitViewModel
    
    @State private var showStyleTagSheet: Bool = false
    @State private var showLocationSheet: Bool = false
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    if let selectedImage = uploadOutfitVM.outfitImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 400)
                            .clipShape((RoundedRectangle(cornerRadius: 10)))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
                
                Form {
                    Section(header: Text("style").foregroundStyle(Color.coffee)) {
                        Button(action: {
                            showStyleTagSheet = true
                        }) {
                            HStack {
                                Image(systemName: "tag")
                                Text(uploadOutfitVM.styleTags.isEmpty ? "Select Tags" : uploadOutfitVM.styleTags.joined(separator: ", "))
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .sheet(isPresented: $showStyleTagSheet) {
                            ZStack {
                                Color.softBeige.ignoresSafeArea()
                                StyleTagView(showStyleTagSheet: $showStyleTagSheet)
                                    .presentationDetents([.medium])
                            }
                        }
                        .sheet(isPresented: $showLocationSheet) {
                            ZStack {
                                Color.softBeige.ignoresSafeArea()
                                OutfitLocationView(showLocationSheet: $showLocationSheet)
                            }
                        }
                    }
                    
                    Section(header: Text("ratings").foregroundStyle(Color.coffee)) {
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
                                .foregroundStyle(Color.coffee)
                            Toggle("Make Public", isOn: $uploadOutfitVM.isPublic)
                        }
                    }
                }
                .colorScheme(.light)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                
                Spacer()
                
                Button {
                    Task {
                        await uploadOutfitVM.saveOutfit(userId: authController.currentUserId)
                        onComplete()
                    }
                } label: {
                    Text("Add")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .background(Color.coffee)
                }
                .cornerRadius(10)
                .padding()
            }
            .background(Color.softBeige)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("new outfit")
                        .font(.headline)
                        .foregroundStyle(Color.chocolate)
                }
            }
            
            if uploadOutfitVM.isLoading {
                LoadingView()
                    .transition(.opacity)
            }
        }
    }
}
