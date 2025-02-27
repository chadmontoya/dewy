import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground.ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .black))
        }
    }
}
