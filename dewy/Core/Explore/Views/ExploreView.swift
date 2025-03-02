import SwiftUI
import SimpleToast
import Shimmer

struct ExploreView: View {
    @EnvironmentObject var authController: AuthController
    
    @ObservedObject var preferencesVM: PreferencesViewModel
    @ObservedObject var collectionsVM: CollectionsViewModel
    
    @StateObject var cardsVM = CardsViewModel(service: CardService())
    
    let userId: UUID
    
    private let toastOptions = SimpleToastOptions(
        alignment: .top,
        hideAfter: 2,
        animation: .easeInOut,
        modifierType: .slide
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("explore")
                        .font(.title3)
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Button {
                        preferencesVM.showPreferences = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                
                ZStack {
                    Color.primaryBackground.ignoresSafeArea()
                    
                    if cardsVM.isLoading {
                        ZStack {
                            ShimmerCardView()
                        }
                    } else {
                        ForEach(cardsVM.outfitCards) { outfitCard in
                            CardView(
                                cardsVM: cardsVM,
                                collectionsVM: collectionsVM,
                                userId: userId,
                                model: outfitCard
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .background(Color.primaryBackground.ignoresSafeArea())
            .fullScreenCover(isPresented: $preferencesVM.showPreferences) {
                PreferencesView(preferencesVM: preferencesVM, cardsVM: cardsVM)
            }
            .sheet(isPresented: $collectionsVM.saveToCollection) {
                CollectionsList(collectionsVM: collectionsVM)
            }
            .simpleToast(isPresented: $collectionsVM.showOutfitAddedToast, options: toastOptions) {
                ToastMessage(iconName: "checkmark.circle", message: "Successfully added outfit to collection")
            }
            .onChange(of: cardsVM.outfitCards) { oldValue, newValue in
                if newValue.isEmpty {
                    Task {
                        if let userId = authController.session?.user.id {
                            await cardsVM.fetchOutfitCards(userId: userId)
                        }
                    }
                }
            }
        }
        .onAppear {
            if let userId = authController.session?.user.id {
                Task {
                    await preferencesVM.fetchPreferences(userId: userId)
                    await collectionsVM.fetchCollections(userId: userId)
                    if cardsVM.outfitCards.isEmpty {
                        await cardsVM.fetchOutfitCards(userId: userId)
                    }
                }
            }
        }
    }
}
