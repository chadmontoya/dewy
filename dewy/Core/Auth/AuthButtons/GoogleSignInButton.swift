import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct GoogleSignInButton: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: {
            Task {
                await authViewModel.handleGoogleSignIn()
            }
        }) {
            HStack {
                Image("google_logo_dark")
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(.white)
            .frame(width: 300, height: 50)
            .background(Color.black)
            .clipShape(Capsule())
        }
    }
}
