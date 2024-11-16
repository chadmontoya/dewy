import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @ObservedObject var vm = GoogleSignInButtonViewModel()
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    GoogleSignInButton(viewModel: vm, action: authViewModel.signIn)
                        .accessibilityIdentifier("GoogleSignInButton")
                        .accessibility(hint: Text("Sign in with Google button."))
                        .padding()
                    
                    VStack {
                        HStack {
                            
                        }
                    }
                }
            }
        }
    }
}
