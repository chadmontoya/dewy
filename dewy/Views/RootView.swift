import Auth
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authController: AuthController
    
    var body: some View {
        if authController.isLoading {
            LoadingView()
        }
        else if authController.session == nil {
            AuthView()
        }
        else {
            HomeView()
        }
    }
}
