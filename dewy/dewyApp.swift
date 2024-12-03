import SwiftUI
import GoogleSignIn

@main
struct dewyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(AuthController())
                .onOpenURL {
                    supabase.handle($0)
                }
        }
    }
}
