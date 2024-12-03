import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("dewy")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 50)
            
            HStack {
                VStack {
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(), action: {
                        Task {
                            do {
                                try await authViewModel.signInWithGoogle()
                                print("successfully signed in")
                            }
                            catch {
                                print("error signing in")
                            }
                        }
                    })
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

