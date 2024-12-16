import SwiftUI

struct OutfitDetailsView: View {
    @EnvironmentObject var uploadOutfitVM: UploadOutfitViewModel
    
    @State private var showStyleTagSheet: Bool = false
    @State private var showLocationSheet: Bool = false
    @State private var selectedStyleTags: Set<String> = []
    
    var body: some View {
        VStack {
            HStack {
                if let selectedImage = uploadOutfitVM.outfitImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 450)
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
                            Text(selectedStyleTags.isEmpty ? "Select Tags" : selectedStyleTags.joined(separator: ", "))
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
                            StyleTagView(selectedStyleTags: $selectedStyleTags)
                                .presentationDetents([.medium])
                        }
                    }
                    .sheet(isPresented: $showLocationSheet) {
                        ZStack {
                            Color.softBeige.ignoresSafeArea()
                        }
                    }
                }
                
                Section(header: Text("ratings").foregroundStyle(Color.coffee)) {
                    Button(action: {
                        showLocationSheet = true
                    }) {
                        HStack {
                            Text("Set Location")
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    Toggle("Make Public", isOn: $uploadOutfitVM.isPublic)
                }
            }
            .colorScheme(.light)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
        }
        .background(Color.softBeige)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("new outfit")
                    .font(.headline)
                    .foregroundStyle(Color.chocolate)
            }
        }
    }
}
