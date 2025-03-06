import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct GoogleAuth: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject private var buttonViewModel = GoogleSignInButtonViewModel()
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        buttonViewModel.style = .wide
        buttonViewModel.scheme = .dark
    }
    
    var body: some View {
        GoogleSignInButton(viewModel: buttonViewModel) {
            Task {
                await authViewModel.handleGoogleSignIn()
            }
        }
            .frame(width: 250, height: 45)
            .padding(.vertical, 5)
    }
}
