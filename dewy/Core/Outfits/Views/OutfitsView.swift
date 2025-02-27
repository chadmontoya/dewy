import SwiftUI
import SimpleToast

struct OutfitsView: View {
    @EnvironmentObject var authController: AuthController
    @Namespace private var animation
    @State private var navigationPath: [String] = []
    @StateObject private var outfitsVM = OutfitsViewModel(
        outfitService: OutfitService(),
        styleService: StyleService()
    )
    
    let columns = Array(repeating: GridItem(spacing: 10), count: 2)
    
    private let toastOptions = SimpleToastOptions(
        alignment: .top,
        hideAfter: 4,
        animation: .easeInOut,
        modifierType: .slide
    )
    
    var body: some View {
        Group {
            NavigationStack {
                VStack {
                    HStack {
                        Text("outfits")
                            .font(.title3)
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Button {
                            outfitsVM.uploadOutfit = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    
                    OutfitList(screenSize: UIScreen.main.bounds.size)
                }
                .background(Color.primaryBackground.ignoresSafeArea())
                .navigationDestination(for: Outfit.self) { outfit in
                    OutfitDetailView(outfit: outfit, animation: animation)
                        .toolbarVisibility(.hidden, for: .navigationBar)
                }
                .navigationDestination(isPresented: $outfitsVM.uploadOutfit) {
                    UploadOutfitView(onComplete: {
                        navigationPath.removeAll()
                    })
                    .toolbarRole(.editor)
                }
                .simpleToast(isPresented: $outfitsVM.showOutfitDeletedToast, options: toastOptions) {
                    ToastMessage(iconName: "checkmark.circle", message: "Successfully deleted outfit")
                }
                .simpleToast(isPresented: $outfitsVM.showOutfitAddedToast, options: toastOptions) {
                    ToastMessage(iconName: "checkmark.circle", message: "Successfully deleted outfit")
                }
            }
            .environmentObject(outfitsVM)
        }
        .onAppear {
            Task {
                if let userId = authController.session?.user.id {
                    await outfitsVM.fetchOutfits(userId: userId)
                }
            }
        }
    }
    
    func OutfitList(screenSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(outfitsVM.outfits) { outfit in
                    NavigationLink(value: outfit) {
                        OutfitCardView(screenSize: screenSize, outfit: outfit)
                            .frame(height: screenSize.height * 0.4)
                            .matchedTransitionSource(id: outfit.id, in: animation) {
                                $0
                                    .background(.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}
