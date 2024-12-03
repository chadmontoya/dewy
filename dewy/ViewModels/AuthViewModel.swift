import SwiftUI
import GoogleSignIn

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: AppUser?
    
    var state: AuthenticationState {
        user != nil ? .signedIn : .signedOut
    }
    
    enum AuthenticationState {
        case signedIn
        case signedOut
    }
    
    func signInWithGoogle() async throws {
        guard let rootViewController = getRootViewController() else {
            print("couldn't get root view controller")
            return
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            print("no id token found")
            return
        }
        
        let accessToken = result.user.accessToken.tokenString
        
        let user = try await AuthManager.shared.signInWithGoogle(idToken: idToken, accessToken: accessToken)
        self.user = user
    }
    
    func signOut() async throws {
        try await AuthManager.shared.signOut()
        self.user = nil
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as?
                UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }
    
    private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController!)
        }
        
        if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController!)
        }
        
        if let presented = vc.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        
        return vc
        
    }
}
