import SwiftUI

struct ClosetView: View {
    @Binding var uploadOutfit: Bool
    
    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            
            VStack {
                Button {
                    uploadOutfit = true
                } label: {
                    Text("Upload Outfit")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .background(Color.coffee)
                }
                .cornerRadius(10)
            }
            .padding()
        }
    }
}
