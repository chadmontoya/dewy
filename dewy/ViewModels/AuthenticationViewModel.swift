import SwiftUI
import GoogleSignIn

final class AuthenticationViewModel: ObservableObject {
    
    let googleAuth = GoogleAuth()
    
    @Published var state: State
    private var authenticator: GoogleSignInAuthenticator {
        return GoogleSignInAuthenticator(authViewModel: self)
    }
    
    init() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            self.state = .signedIn(user)
        }
        else {
            self.state = .signedOut
        }
    }
    
    func signIn() {
        authenticator.signIn()
    }
    
    func signOut() {
        authenticator.signOut()
    }
    
    func disconnect() {
        authenticator.disconnect()
    }
    
}

extension AuthenticationViewModel {
    enum State {
        case signedIn(GIDGoogleUser)
        case signedOut
    }
}
