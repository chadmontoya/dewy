import SwiftUI
import GoogleSignIn

@main
struct dewyApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear(perform: restorePreviousSignIn)
                .onOpenURL(perform: handleURL)
        }
    }
        
    private func handleURL(_ url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }

    private func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user {
                self.authViewModel.state = .signedIn(user)
            }
            else if let error = error {
                self.authViewModel.state = .signedOut
                print("there was an error restoring the previous sign in: \(error)")
            }
            else {
                self.authViewModel.state = .signedOut
            }
        }
    }
}
