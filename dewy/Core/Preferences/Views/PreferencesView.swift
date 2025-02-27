import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var authController: AuthController
    @ObservedObject var preferencesVM: PreferencesViewModel
    @ObservedObject var cardsVM: CardsViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()
                
                List {
                    PreferenceRow(title: "I'm interested in outfits from", value: preferencesVM.genderPreferenceText)
                        .background(
                            NavigationLink("", destination: GenderPreferenceView(preferencesVM:  preferencesVM)).opacity(0)
                        )
                    PreferenceRow(title: "Age range", value: preferencesVM.agePreferenceText)
                        .background(
                            NavigationLink("", destination: AgePreferenceView(preferencesVM: preferencesVM)).opacity(0)
                        )
                    PreferenceRow(title: "My location", value: preferencesVM.cityLocation)
                        .background(
                            NavigationLink("", destination: LocationPreferenceView(preferencesVM: preferencesVM)).opacity(0)
                        )
                    PreferenceRow(title: "Outfit styles", value: preferencesVM.stylePreferenceText)
                        .background(
                            NavigationLink("", destination: StylePreferenceView(preferencesVM: preferencesVM)).opacity(0)
                        )
                }
                .contentMargins(.vertical, 0)
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Preferences")
                            .foregroundStyle(Color.black)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                if let userId = authController.session?.user.id {
                                    try await preferencesVM.savePreferences(userId: userId)
                                    await cardsVM.fetchOutfitCards(userId: userId)
                                }
                            }
                            preferencesVM.showPreferences = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.black)
                        }
                    }
                }
            }
        }
        .tint(.black)
    }
}

struct PreferenceRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundStyle(Color.black)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color.black)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 7)
                .foregroundStyle(.black)
        }
        .listRowBackground(Color.primaryBackground)
        .listRowSeparatorTint(Color.black)
        .listSectionSeparator(.hidden, edges: .top)
    }
}
