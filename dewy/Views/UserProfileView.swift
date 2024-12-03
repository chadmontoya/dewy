import SwiftUI
import GoogleSignIn

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        return Group {
            if let appUser = authViewModel.user {
                VStack() {
                    Text("hello, \(appUser.email!)").font(.title)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            do {
                                try await authViewModel.signOut()
                            }
                            catch {
                                print("sign out error")
                            }
                        }
                    } label: {
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
        .onAppear(perform: {
            Task {
                try await AuthManager.shared.getSession()
            }
        })
    }
}
