import Foundation
import GoogleSignIn

final class GoogleSignInAuthenticator: ObservableObject {
    private var authViewModel: AuthenticationViewModel
    
    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
    }
    
    func signIn() {
        guard let rootViewController = getRootViewController() else {
            print("there is no root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard let signInResult = signInResult else {
                print("error \(String(describing: error))")
                return
            }
            
            self.authViewModel.state = .signedIn(signInResult.user)
            print(self.authViewModel.state)
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        authViewModel.state = .signedOut
    }
    
    func disconnect() {
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("encountered error disconnecting scope: \(error)")
            }
            self.signOut()
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
