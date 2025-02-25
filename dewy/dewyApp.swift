import SwiftUI

@main
struct dewyApp: App {
    @StateObject private var authController = AuthController()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL {
                    supabase.handle($0)
                }
                .environmentObject(authController)
                .tint(.black)
        }
    }
}

extension Color {
    static let primaryBackground = Color.white
    static let secondaryBackground = Color.white
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
