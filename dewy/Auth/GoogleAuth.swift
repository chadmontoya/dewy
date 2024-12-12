import GoogleSignIn
import GoogleSignInSwift
import Supabase
import SwiftUI

@MainActor
struct GoogleAuth: View {
    @ObservedObject var vm = GoogleSignInButtonViewModel()
    @Binding var authState: ActionState<Void, Error>
    
    init(authState: Binding<ActionState<Void, Error>>) {
        self._authState = authState
        vm.style = .wide
        vm.scheme = .dark
    }
    
    var body: some View {
        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide), action: handleSignIn)
            .frame(width: 250, height: 45)
            .padding(.vertical, 5)
    }
    
    private func handleSignIn() {
        Task {
            do {
                withAnimation {
                    authState = .inFlight
                }
                
                guard let rootViewController = getRootViewController() else {
                    print("unable to get root view controller")
                    return
                }
                
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                
                guard let idToken = result.user.idToken?.tokenString else {
                    print("no id token found from GIDSignIn")
                    return
                }
                
                let accessToken = result.user.accessToken.tokenString
                
                try await supabase.auth.signInWithIdToken(
                    credentials: OpenIDConnectCredentials(
                        provider: .google,
                        idToken: idToken,
                        accessToken: accessToken
                    )
                )
                
                authState = .result(.success(()))
            }
            catch {
                withAnimation {
                    authState = .idle
                }
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
