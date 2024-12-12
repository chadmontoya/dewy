import Auth
import SwiftUI

@MainActor
class AuthController: ObservableObject {
    @Published var session: Session?
    @Published var hasProfile: Bool = false
    @Published var isLoading: Bool = true
    
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
                    
                    if session?.user.id != nil {
                        await self.checkUserProfile()
                    }
                    else {
                        isLoading = false
                    }
                }
            }
        }
    }
    
    deinit {
        observeAuthStateChangesTask?.cancel()
    }
    
    func checkUserProfile() async {
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
