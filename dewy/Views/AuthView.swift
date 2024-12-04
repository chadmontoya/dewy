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
    var body: some View {
        ZStack {
            Color.cream
                .ignoresSafeArea()
                .onTapGesture {
                    self.hideKeyboard()
                }
            
            VStack {
                Spacer()
                
                AuthWithEmailAndPassword()
                
                HStack {
                    Line()
                    Text("or")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Line()
                }
                .padding(.horizontal)
                
                VStack {
                    GoogleAuth()
                    
                    AppleAuth()
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
