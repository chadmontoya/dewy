import AuthenticationServices
import SwiftUI

struct AppleAuth: View {
    @State private var actionState = ActionState<Void, Error>.idle
    
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
                    await handleSignIn(using: identityToken)
                }
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(width: 250, height: 45, alignment: .center)
        
        switch actionState {
        case .idle, .result(.success):
            EmptyView()
        case .inFlight:
            ProgressView()
        case let .result(.failure(error)):
            Text(error.localizedDescription)
                .foregroundColor(.red)
                .font(.footnote)
                .padding(.horizontal)
        }
    }
    
    private func handleSignIn(using idToken: String) async {
        actionState = .inFlight
        let result = await Result {
            _ = try await supabase.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken))
        }
        actionState = .result(result)
    }
}
