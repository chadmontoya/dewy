import Auth
import SwiftUI

struct RootView: View {
    @Environment(AuthController.self) var auth
    
    var body: some View {
        if auth.session == nil {
            AuthView()
        }
        else {
            HomeView()
        }
    }
}

extension Color {
    static let cream = Color(red: 245 / 255, green: 245 / 255, blue: 220 / 255)
    static let softBeige = Color(red: 240 / 255, green: 230 / 255, blue: 210 / 255)
    static let warmBrown = Color(red: 139 / 255, green: 94 / 255, blue: 60 / 255)
    static let chocolate = Color(red: 93 / 255, green: 64 / 255, blue: 55 / 255)
    static let coffee = Color(red: 111 / 255, green: 78 / 255, blue: 55 / 255)
    static let mutedTaupe = Color(red: 210 / 255, green: 180 / 255, blue: 140 / 255)
    static let lightSand = Color(red: 233 / 255, green: 220 / 255, blue: 201 / 255)
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
