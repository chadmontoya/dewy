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
                LocationSelectView()
            }
            .tabItem {
                Label("Location", systemImage: "message.fill")
            }
            
            NavigationStack {
                ProfileView(user: user)
//                ProfileViewWIP()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}
