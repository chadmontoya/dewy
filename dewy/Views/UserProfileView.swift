import SwiftUI
import GoogleSignIn

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    var body: some View {
        return Group {
            if let userProfile = user?.profile {
                VStack() {
                    Text("Hello, \(userProfile.name)").font(.title)
                    
                    Spacer()
                    
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
    }
}
