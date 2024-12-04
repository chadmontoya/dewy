import Auth
import SwiftUI

@Observable
@MainActor
final class AuthController {
    var session: Session?
    
    var currentUserId: UUID {
        guard let id = session?.user.id else {
            preconditionFailure("no session")
        }
        return id
    }
    
    @ObservationIgnored
    private var observeAuthStateChangesTask: Task<Void, Never>?
    
    init() {
        observeAuthStateChangesTask = Task {
            for await (event, session) in supabase.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(event) {
                    self.session = session
                }
            }
        }
    }
    
    deinit {
        observeAuthStateChangesTask?.cancel()
    }
}
