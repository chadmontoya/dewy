import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var preferencesVM: PreferencesViewModel
    
    @State private var showPreferences = false
    @State private var saveToCollection = false
    
    @StateObject var cardsVM = CardsViewModel(service: CardService())
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()
                
                ForEach(cardsVM.outfitCards) { outfitCard in
                    CardView(cardsVM: cardsVM, saveToCollection: $saveToCollection, model: outfitCard)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPreferences = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(Color.coffee)
                    }
                }
            }
            .fullScreenCover(
                isPresented: $showPreferences
            ) {
                PreferencesView(preferencesVM: preferencesVM, cardsVM: cardsVM, showPreferences: $showPreferences)
            }
            .sheet(isPresented: $saveToCollection) {
                CollectionsList()
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
                }
            }
        }
    }
}
