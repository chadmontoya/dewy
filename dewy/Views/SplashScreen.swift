import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            
            Text("dewy")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    SplashScreen()
}
