import Auth
import SwiftUI

@MainActor
class AuthController: ObservableObject {
    @Published var session: Session?
    @Published var isLoading: Bool = true
    @Published var requireOnboarding: Bool = true
    
    @ObservationIgnored
    private var observeAuthStateChangesTask: Task<Void, Never>?
    
    init() {
        setupAuthStateObserver()
    }
    
    deinit {
        observeAuthStateChangesTask?.cancel()
    }
    
    func checkUserProfile() async {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            let count = try await supabase
                .from("Profiles")
                .select("*", head: true, count: .exact)
                .eq("user_id", value: session?.user.id)
                .execute()
                .count
            
            requireOnboarding = (count == 0)
            print("require onboarding: \(requireOnboarding)")
        }
        catch {
            print("error checking if profile exists: \(error)")
        }
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
