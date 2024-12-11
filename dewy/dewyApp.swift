import SwiftUI
import GoogleSignIn

@main
struct dewyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
                    .environment(AuthController())
                    .onOpenURL {
                        supabase.handle($0)
                    }
            }
            .tint(Color.coffee)
        }
    }
}
