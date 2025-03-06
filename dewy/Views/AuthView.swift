import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
                .onTapGesture {
                    self.hideKeyboard()
                }
            
            VStack {
                Spacer()
                
                EmailPasswordAuth(authViewModel: authViewModel)
                
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 125, height: 1)
                    
                    Text("or")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 125, height: 1)
                }
                .padding(.horizontal)
                
                VStack {
                    GoogleAuth(authViewModel: authViewModel)
                    AppleAuth(authViewModel: authViewModel)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if case .inFlight = authViewModel.authState {
                SplashScreen()
                    .onAppear {
                        hideKeyboard()
                    }
            }
            
        }
        .ignoresSafeArea(.keyboard)
    }
}
