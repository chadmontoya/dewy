import Supabase
import SwiftUI

struct HomeView: View {
    @Environment(AuthController.self) var auth
    
    var body: some View {
        @Bindable var auth = auth
        
        Text("hello, \(auth.session?.user.email ?? "no email")")
        
        Button("sign out", role: .destructive) {
            Task {
                try await supabase.auth.signOut()
            }
        }
    }
}
