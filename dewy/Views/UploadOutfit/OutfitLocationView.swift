import SwiftUI
import MapKit

struct OutfitLocationView: View {
    @EnvironmentObject var uploadOutfitVM: UploadOutfitViewModel
    
    @Binding var showLocationSheet: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            MapView(location: $uploadOutfitVM.location)
            
            Button {
                showLocationSheet = false
            } label: {
                Text("Update")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(Color.coffee)
            }
            .cornerRadius(10)
            .padding()
        }
    }
}
