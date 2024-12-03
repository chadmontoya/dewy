import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("dewy")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 50)
            
            HStack {
                VStack {
                    GoogleSignIn()
                }
            }
            
            Spacer()
        }
    }
}

