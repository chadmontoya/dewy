import SwiftUI

struct PreferencesView: View {
    @StateObject private var preferencesVM: PreferencesViewModel = PreferencesViewModel(styleService: StyleService())
    
    @Binding var showPreferences: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.softBeige.ignoresSafeArea()
                
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
                    PreferenceRow(title: "Styles", value: "")
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
                            showPreferences = false
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
        .listRowBackground(Color.softBeige)
        .listRowSeparatorTint(Color.black)
        .listSectionSeparator(.hidden, edges: .top)
    }
}
