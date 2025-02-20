import SwiftUI

struct EmailPasswordAuth: View {
    enum Mode {
        case signIn, signUp
    }
    
    enum Result {
        case needsEmailConfirmation
    }
    
    @Binding var authState: ActionState<Void, Error>
    @State private var email = ""
    @State private var password = ""
    @State private var mode: Mode = .signUp
    @State private var isPresentingResetPassword = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack() {
            headerSection
            
            VStack(spacing: 16) {
                emailField
                
                passwordField
                
                primaryActionButton
                
                errorMessageView
            }
            .padding()
            
            modeToggleButton
        }
        .animation(.snappy, value: mode)
    }
    
    private var headerSection: some View {
        VStack() {
            Text(mode == .signIn ? "Sign In" : "Sign Up")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
    }
    
    private var emailField: some View {
        TextField("", text: $email, prompt: Text("Email").foregroundStyle(.gray))
            .foregroundStyle(.black)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(email.isEmpty ? Color.gray.opacity(0.3) : Color.mutedTaupe, lineWidth: 1)
            )
    }
    
    private var passwordField: some View {
        HStack {
            Group {
                if isPasswordVisible {
                    TextField("", text: $password, prompt: Text("Password").foregroundStyle(.gray))
                } else {
                    SecureField("", text: $password, prompt: Text("Password").foregroundStyle(.gray))
                }
            }
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .foregroundStyle(.black)
            
            Button(action: { isPasswordVisible.toggle() }) {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(password.isEmpty ? Color.gray.opacity(0.3) : Color.mutedTaupe, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        )
    }
    
    private var primaryActionButton: some View {
        Button(action: { Task { await primaryActionButtonTapped() } }) {
            Group {
                Text(mode == .signIn ? "Sign In" : "Sign Up")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isActionEnabled ? .black: .black.opacity(0.5)
            )
            .cornerRadius(10)
        }
        .disabled(!isActionEnabled)
    }
    
    private var errorMessageView: some View {
        Group {
            switch authState {
            case .result(.failure(let error)):
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            default:
                EmptyView()
            }
        }
    }
    
    private var modeToggleButton: some View {
        HStack {
            Text(mode == .signIn ? "Don't have an account?" : "Already have an account?")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            Button(mode == .signIn ? "Sign up" : "Sign in") {
                withAnimation(.snappy) {
                    toggleMode()
                }
            }
            .foregroundColor(.blue)
            .font(.subheadline)
        }
        .padding(.bottom, 40)
    }
    
    private var isActionEnabled: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    @MainActor
    private func primaryActionButtonTapped() async {
        do {
            authState = .inFlight
            
            switch mode {
            case .signIn:
                try await signIn()
            case .signUp:
                try await signUp()
            }
        } catch {
            withAnimation {
                authState = .result(.failure(error))
            }
        }
    }
    
    @MainActor
    private func signIn() async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }
    
    @MainActor
    private func signUp() async throws {
        try await supabase.auth.signUp(email: email, password: password)
    }
    
    private func toggleMode() {
        mode = mode == .signIn ? .signUp : .signIn
        
        email = ""
        password = ""
        isPasswordVisible = false
    }
}
