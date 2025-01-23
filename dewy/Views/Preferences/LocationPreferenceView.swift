import SwiftUI

struct LocationPreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var preferencesVM: PreferencesViewModel
    
    var body: some View {
        ZStack {
            Color.softBeige.ignoresSafeArea()
            
            MapView(location: $preferencesVM.location)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Location")
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
