@preconcurrency import GoogleSignIn
import GoogleSignInSwift
import Supabase
import SwiftUI

@MainActor
struct GoogleSignIn: View {
    var body: some View {
        GoogleSignInButton(action: handleSignIn)
            .accessibilityIdentifier("GoogleSignInButton")
            .accessibility(hint: Text("Sign in with Google Button."))
            .padding()
            .frame(maxWidth: 280)
    }
    
    func handleSignIn() {
        Task {
            do {
                guard let rootViewController = getRootViewController() else {
                    print("cant get root view controller")
                    return
                }
                
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                
                guard let idToken = result.user.idToken?.tokenString else {
                    print("no id token found from GIDSignIn")
                    return
                }
                
                try await supabase.auth.signInWithIdToken(
                    credentials: OpenIDConnectCredentials(
                        provider: .google,
                        idToken: idToken
                    )
                )
            }
            catch {
                print("google sign in failed: \(error)")
            }
        }
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
