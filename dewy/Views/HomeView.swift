import Supabase
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authController: AuthController
    
    var body: some View {
        
        Text("hello, \(authController.session?.user.email ?? "no email")")
        
        Button("sign out", role: .destructive) {
            Task {
                try await supabase.auth.signOut()
            }
        }
    }
}
