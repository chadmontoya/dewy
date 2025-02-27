import SwiftUI
import GoogleSignInSwift

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 125, height: 1)
    }
}

struct AuthView: View {
    @State private var authState: ActionState<Void, Error> = .idle
    
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
                .onTapGesture {
                    self.hideKeyboard()
                }
            
            VStack {
                Spacer()
                
                EmailPasswordAuth(authState: $authState)
                
                HStack {
                    Line()
                    Text("or")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Line()
                }
                .padding(.horizontal)
                
                VStack {
                    GoogleAuth(authState: $authState)
                    
                    AppleAuth()
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if case .inFlight = authState {
                SplashScreen()
                    .onAppear {
                        hideKeyboard()
                    }
            }
            
        }
        .ignoresSafeArea(.keyboard)
    }
}
