import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authController: AuthController
    
    @ObservedObject var preferencesVM: PreferencesViewModel
    @ObservedObject var collectionsVM: CollectionsViewModel
    
    @StateObject var cardsVM = CardsViewModel(service: CardService())
    
    let userId: UUID
    
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
                    
                    ForEach(cardsVM.outfitCards) { outfitCard in
                        CardView(
                            cardsVM: cardsVM,
                            collectionsVM: collectionsVM,
                            userId: userId,
                            model: outfitCard
                        )
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
                    await cardsVM.fetchOutfitCards(userId: userId)
                    await collectionsVM.fetchCollections(userId: userId)
                }
            }
        }
    }
}
