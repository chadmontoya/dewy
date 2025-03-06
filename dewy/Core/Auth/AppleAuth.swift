import AuthenticationServices
import SwiftUI

struct AppleAuth: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        SignInWithAppleButton(.continue) { request in
            request.requestedScopes = [.email]
        }
        onCompletion: { result in
            switch result {
            case let .failure(error):
                print("apple sign in error: \(error)")
            case let .success(authorization):
                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    print("invalid apple id credential")
                    return
                }
                
                guard let identityToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8)}) else {
                    print("invalid identity token")
                    return
                }
                
                Task {
                    await authViewModel.handleAppleSignIn(using: identityToken)
                }
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(width: 250, height: 45, alignment: .center)
    }
}
