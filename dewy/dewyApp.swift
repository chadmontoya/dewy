import SwiftUI
import GoogleSignIn

@main
struct dewyApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onOpenURL(perform: handleURL)
                .onAppear(perform: {
                    Task {
                        try await AuthManager.shared.getSession()
                    }
                })
        }
    }
        
    private func handleURL(_ url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
}
