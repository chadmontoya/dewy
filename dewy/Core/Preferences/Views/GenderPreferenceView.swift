import SwiftUI

struct GenderPreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var preferencesVM: PreferencesViewModel
    
    var body: some View {
        ZStack {
            Color.primaryBackground.ignoresSafeArea()
            
            List {
                Button(action: { preferencesVM.selectAllGenders() }) {
                    HStack {
                        Text("Everyone")
                            .foregroundStyle(.black)
                        Spacer()
                        if preferencesVM.allGendersSelected {
                            Image(systemName: "checkmark.square")
                                .foregroundStyle(Color.black)
                                .fontWeight(.semibold)
                        }
                        else {
                            Image(systemName: "square")
                                .foregroundStyle(Color.black)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .listRowBackground(Color.primaryBackground)
                
                ForEach(Gender.GenderType.allCases, id: \.self) { genderType in
                    Button(action: { preferencesVM.toggleGender(genderType) }) {
                        HStack {
                            Text(genderType.preferenceDisplayName)
                                .foregroundStyle(.black)
                            Spacer()
                            if preferencesVM.selectedGenders.contains(Gender(type: genderType)) {
                                Image(systemName: "checkmark.square")
                                    .foregroundStyle(Color.black)
                                    .fontWeight(.semibold)
                            }
                            else {
                                Image(systemName: "square")
                                    .foregroundStyle(Color.black)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .listRowBackground(Color.primaryBackground)
                }
            }
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Gender Preference")
                        .foregroundStyle(Color.black)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}
