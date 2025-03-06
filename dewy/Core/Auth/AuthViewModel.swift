import SwiftUI
import Supabase
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: ActionState<Void, Error> = .idle
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var mode: AuthMode = .signUp
    @Published var isPasswordVisible: Bool = false
    
    var isActionEnabled: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    enum AuthMode {
        case signIn
        case signUp
    }
    
    func emailPasswordSignIn() async throws {
        authState = .inFlight
        do {
            try await supabase.auth.signIn(email: email, password: password)
            authState = .result(.success(()))
        } catch {
            authState = .result(.failure(error))
        }
    }
    
    func emailPasswordSignUp() async throws {
        authState = .inFlight
        do {
            try await supabase.auth.signUp(email: email, password: password)
            authState = .result(.success(()))
        } catch {
            authState = .result(.failure(error))
        }
    }
    
    func toggleMode() {
        mode = mode == .signIn ? .signUp : .signIn
        email = ""
        password = ""
        isPasswordVisible = false
    }
    
    // TODO: figure out way to get id token and finish method
    
    func handleAppleSignIn(using idToken: String) async {
        do {
            authState = .inFlight
            try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken
                )
            )
            authState = .result(.success(()))
        } catch {
            authState = .idle
            print("apple sign in failed: \(error)")
        }
    }
    
    func handleGoogleSignIn() async {
        do {
            authState = .inFlight
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
        } catch {
            authState = .idle
            print("google sign in failed: \(error)")
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
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
