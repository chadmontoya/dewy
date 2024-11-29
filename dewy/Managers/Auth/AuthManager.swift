import Foundation
import Supabase

struct AppUser {
    let uid: String
    let email: String?
}

class AuthManager {
    
    static let shared = AuthManager()
    
    private init() {}
    
    static let supabaseURL: URL = URL(string: "https://riycadlhyixpkdpvxhpx.supabase.co")!
    static let supabaseKey: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpeWNhZGxoeWl4cGtkcHZ4aHB4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI3Mzg4NTksImV4cCI6MjA0ODMxNDg1OX0.zigMLxHXcDCGpGyVyz-n-6CmUkGpLUFpJTbd1MQkr6w"
    
    let client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    
    func signInWithGoogle(idToken: String, nonce: String) async throws -> AppUser {
        let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken, nonce: nonce))
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
}
