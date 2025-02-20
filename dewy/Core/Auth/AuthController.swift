import Auth
import SwiftUI

@MainActor
class AuthController: ObservableObject {
    @Published var session: Session?
    @Published var isLoading: Bool = true
    @Published var requireOnboarding: Bool = false
    
    @ObservationIgnored
    private var observeAuthStateChangesTask: Task<Void, Never>?
    
    init() {
        setupAuthStateObserver()
    }
    
    deinit {
        observeAuthStateChangesTask?.cancel()
    }
    
    func checkUserProfile() async {
        guard let userId = session?.user.id else {
            isLoading = false
            return
        }
        
        isLoading = true
        
        do {
            let count = try await supabase
                .from("Profiles")
                .select("*", head: true, count: .exact)
                .eq("user_id", value: userId)
                .execute()
                .count
            
            requireOnboarding = (count == 0)
        }
        catch {
            print("error checking if profile exists: \(error)")
        }
        
        isLoading = false
    }
    
    private func setupAuthStateObserver() {
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
}
