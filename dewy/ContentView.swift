import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        return Group {
            NavigationView {
                switch authViewModel.state {
                case .signedIn:
                    UserProfileView()
                case .signedOut:
                    AuthenticationView()
                }
            }
        }
    }
}
