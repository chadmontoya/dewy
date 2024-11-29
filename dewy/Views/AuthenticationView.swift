import SwiftUI
import GoogleSignInSwift

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @ObservedObject var vm = GoogleSignInButtonViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("dewy")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 50)
            
            HStack {
                VStack {
                    GoogleSignInButton(viewModel: vm, action: authViewModel.signIn)
                        .accessibilityIdentifier("GoogleSignInButton")
                        .accessibility(hint: Text("Sign in with Google Button."))
                        .padding()
                        .frame(maxWidth: 280)
                }
            }
            
            Spacer()
        }
    }
}

