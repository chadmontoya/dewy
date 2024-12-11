import Auth
import SwiftUI

@Observable
@MainActor
final class AuthController: ObservableObject {
    var session: Session?
    var hasProfile: Bool = false
    var isLoading: Bool = true
    
    var currentUserId: UUID {
        (session?.user.id)!
   }
    
    @ObservationIgnored
    private var observeAuthStateChangesTask: Task<Void, Never>?
    
    init() {
        observeAuthStateChangesTask = Task {
            for await (event, session) in supabase.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(event) {
                    self.session = session
                    
                    if event != .signedOut {
                        if session?.user.id != nil {
                            await checkUserProfile()
                        }
                    }
                    
                }
            }
        }
    }
    
    deinit {
        observeAuthStateChangesTask?.cancel()
    }
    
    private func checkUserProfile() async {
        isLoading = true
        do {
            try await supabase
                .from("Profiles")
                .select()
                .eq("user_id", value: currentUserId)
                .single()
                .execute()
            
            hasProfile = true
        }
        catch {
            hasProfile = false
            print("error checking profile: \(error)")
        }
        isLoading = false
    }
}
