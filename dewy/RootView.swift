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
