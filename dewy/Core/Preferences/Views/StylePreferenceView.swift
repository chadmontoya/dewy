import SwiftUI

struct StylePreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var preferencesVM: PreferencesViewModel
    
    var body: some View {
        ZStack {
            Color.softBeige.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                styleList

                HStack {
                    Button(action: { preferencesVM.selectAllStyles() }) {
                        Image(systemName: preferencesVM.allStylesSelected ? "checkmark.square" : "square")
                            .foregroundStyle(Color.black)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("Interested in all styles")
                        .foregroundStyle(Color.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Outfit Styles")
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
    
    var styleList: some View {
        FlowLayout {
            ForEach(preferencesVM.availableStyles) { style in
                HStack {
                    Text(style.name)
                        .padding()
                        .background(preferencesVM.selectedStyles.contains(style) ? Color.black: .gray)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .onTapGesture {
                            preferencesVM.toggleStyle(style)
                        }
                }
                .padding(5)
            }
        }
    }
}
