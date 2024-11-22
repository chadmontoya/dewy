import SwiftUI
import GoogleSignIn

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let user: GIDGoogleUser
    
    @State private var showingEditProfile = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    AsyncImage(url: user.profile?.imageURL(withDimension: 100)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.profile?.name ?? " ")
                            .font(.title2)
                            .bold()
                        Text(user.profile?.email ?? " ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section {
                HStack {
                    Spacer()
                    VStack {
                        Text("286")
                            .font(.title2)
                            .bold()
                        Text("Matches")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack {
                        Text("1,234")
                            .font(.title2)
                            .bold()
                        Text("Likes")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            Section {
                Button(role: .destructive) {
                    authViewModel.signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                
                Button(role: .destructive) {
                    authViewModel.disconnect()
                } label: {
                    Label("Delete Account", systemImage: "xmark.circle")
                }
            }
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
}
