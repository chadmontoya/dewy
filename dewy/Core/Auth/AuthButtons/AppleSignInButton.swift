import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: {
            
        }) {
            HStack {
                Image(systemName: "apple.logo")
                Text("Sign in with Apple")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(.white)
            .frame(width: 300, height: 50)
            .background(Color.black)
            .clipShape(Capsule())
        }
    }
}
