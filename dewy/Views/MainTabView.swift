import SwiftUI
import GoogleSignIn

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let user: GIDGoogleUser
    
    var body: some View {
        TabView {
            NavigationStack {
                SwipeView(user: user)
            }
            .tabItem {
                Label("Swipe", systemImage: "flame.fill")
            }
            
            NavigationStack {
                SwipeView(user: user)
            }
            .tabItem {
                Label("Swipe 2", systemImage: "message.fill")
            }
            
            NavigationStack {
                ProfileView(user: user)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}
