import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.primaryBackground.ignoresSafeArea()
            
            Text("dewy")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.black)
        }
    }
}
