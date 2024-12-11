import Supabase
import SwiftUI

struct HomeView: View {
    @Environment(AuthController.self) var auth
    
    var body: some View {
        
        if auth.hasProfile {
            Text("hello, \(auth.session?.user.email ?? "no email")")
            
            Button("sign out", role: .destructive) {
                Task {
                    try await supabase.auth.signOut()
                }
            }
        }
        else {
            BirthdayView()
        }
    }
}
