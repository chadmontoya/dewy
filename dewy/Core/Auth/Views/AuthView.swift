import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
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
                            .padding(.bottom, 10)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 125, height: 1)
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        NavigationLink {
                            PhoneNumberInputView(authViewModel: authViewModel)
                                .toolbarRole(.editor)
                        } label: {
                            PhoneSignInButton()
                        }
                        
                        GoogleSignInButton(authViewModel: authViewModel)
                        AppleSignInButton(authViewModel: authViewModel)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if case .authenticating = authViewModel.authState {
                    SplashScreen()
                        .onAppear {
                            hideKeyboard()
                        }
                }
                
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
