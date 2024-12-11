import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.coffee))
        }
    }
}

#Preview {
    LoadingView()
}
