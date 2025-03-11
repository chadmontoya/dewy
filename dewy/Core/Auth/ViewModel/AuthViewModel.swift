import SwiftUI
import Supabase
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthViewModel: ObservableObject {
    
    enum AuthMode {
        case signIn
        case signUp
    }
    
    enum AuthenticationState {
        case idle
        case authenticating
        case authenticated
        case failed(Error)
    }
    
    @Published var authState: AuthenticationState = .idle
    @Published var mode: AuthMode = .signIn
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    
    @Published var phoneNumberExtension: String = "1"
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    @Published var countryCode: String = "US"
    @Published var isCountryCodeSheetPresented: Bool = false
    @Published var sendPhoneOTPError: String? = nil
    @Published var verifyOTPError: String? = nil
    @Published var navigateToVerify: Bool = false
    
    private let minLength = 8
    private let emailRegex = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$"
    private let uppercaseRegex = ".*[A-Z]+.*"
    private let lowercaseRegex = ".*[a-z]+.*"
    private let numberRegex = ".*[0-9]+.*"
    private let specialCharRegex = ".*[^A-Za-z0-9].*"
    
    var fullPhoneNumber: String {
        "\(phoneNumberExtension)\(phoneNumber)"
    }
    
    var isEmailValid: Bool {
        guard let regex = try? NSRegularExpression(pattern: emailRegex) else { return false }
        let range = NSRange(location: 0, length: email.utf16.count)
        return regex.firstMatch(in: email, options: [], range: range) != nil
    }
    
    var passwordValidationStatus: [(requirement: String, isSatisfied: Bool)] {
        [
            ("At least \(minLength) characters", password.count >= minLength),
            ("One uppercase letter", NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password)),
            ("One lowercase letter", NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password)),
            ("One number", NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password)),
            ("One special character", NSPredicate(format: "SELF MATCHES %@", specialCharRegex).evaluate(with: password))
        ]
    }
    
    var isPasswordValid: Bool {
        passwordValidationStatus.allSatisfy { $0.isSatisfied }
    }
    
    var isFormButtonEnabled: Bool {
        if mode == .signUp {
            return !email.isEmpty && !password.isEmpty && isEmailValid && isPasswordValid
        } else {
            return !email.isEmpty && !password.isEmpty && isEmailValid
        }
    }
    
    func emailPasswordSignIn() async throws {
        authState = .authenticating
        do {
            try await supabase.auth.signIn(email: email, password: password)
            authState = .authenticated
        } catch {
            authState = .failed(error)
        }
    }
    
    func emailPasswordSignUp() async throws {
        authState = .authenticating
        do {
            try await supabase.auth.signUp(email: email, password: password)
            authState = .authenticated
        } catch {
            authState = .failed(error)
        }
    }
    
    func sendPhoneVerification() async {
        sendPhoneOTPError = nil
        do {
            try await supabase.auth.signInWithOTP(phone: fullPhoneNumber)
            navigateToVerify = true
        } catch {
            sendPhoneOTPError = "Unable to send code. Please check the number or try again later."
        }
    }
    
    func toggleMode() {
        mode = mode == .signIn ? .signUp : .signIn
        email = ""
        password = ""
        isPasswordVisible = false
        authState = .idle
    }
    
    // TODO: figure out way to get id token and finish method
    
    func handleAppleSignIn(using idToken: String) async throws {
        do {
            try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken
                )
            )
        } catch {
            print("apple sign in failed: \(error)")
        }
    }
    
    func handleGoogleSignIn() async {
        authState = .authenticating
        do {
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
            authState = .authenticated
        } catch {
            authState = .idle
            print("google sign in failed: \(error)")
        }
    }
    
    func resetPhoneAuthState() {
        phoneNumber = ""
        verificationCode = ""
        sendPhoneOTPError = nil
        verifyOTPError = nil
        authState = .idle
    }
    
    func verifyOTP() async {
        authState = .authenticating
        do {
            try await supabase.auth.verifyOTP(
                phone: fullPhoneNumber,
                token: verificationCode,
                type: .sms
            )
            authState = .authenticated
        } catch {
            authState = .idle
            verificationCode = ""
            verifyOTPError = "Invalid code. Please try again."
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
