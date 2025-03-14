import SwiftUI

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
                    .background(.black)
            }
            .cornerRadius(10)
            .padding()
        }
    }
}
