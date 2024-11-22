import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        Group {
            switch authViewModel.state {
            case .signedIn(let user):
                MainTabView(user: user)
                    .environmentObject(authViewModel)
            case .signedOut:
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
