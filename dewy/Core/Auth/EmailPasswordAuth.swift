import SwiftUI

struct EmailPasswordAuth: View {
    @ObservedObject var authViewModel: AuthViewModel
    @FocusState private var isPasswordFieldFocused: Bool
    
    var body: some View {
        VStack() {
            headerSection
            
            VStack(spacing: 16) {
                emailField
                passwordField
                if authViewModel.mode == .signUp &&
                    !authViewModel.password.isEmpty &&
                    isPasswordFieldFocused {
                    passwordValidationList
                }
                primaryActionButton
                errorMessageView
            }
            .padding()
            
            modeToggleButton
        }
    }
    
    private var headerSection: some View {
        VStack() {
            Text(authViewModel.mode == .signIn ? "Sign In" : "Sign Up")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
    }
    
    private var emailField: some View {
        TextField("", text: $authViewModel.email, prompt: Text("Email").foregroundStyle(.gray))
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
                    .stroke(authViewModel.email.isEmpty ? Color.gray.opacity(0.3) : .black, lineWidth: 1)
            )
    }
    
    private var passwordField: some View {
        HStack {
            Group {
                if authViewModel.isPasswordVisible {
                    TextField("", text: $authViewModel.password, prompt: Text("Password").foregroundStyle(.gray))
                        .focused($isPasswordFieldFocused)
                } else {
                    SecureField("", text: $authViewModel.password, prompt: Text("Password").foregroundStyle(.gray))
                        .focused($isPasswordFieldFocused)
                }
            }
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .foregroundStyle(.black)
            
            Button(action: { authViewModel.isPasswordVisible.toggle() }) {
                Image(systemName: authViewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(authViewModel.password.isEmpty ? Color.gray.opacity(0.3) : .black, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        )
    }
    
    private var primaryActionButton: some View {
        Button(action: {
            Task {
                try await authViewModel.mode == .signIn ? authViewModel.emailPasswordSignIn() : authViewModel.emailPasswordSignUp()
            }
        }) {
            Group {
                Text(authViewModel.mode == .signIn ? "Sign In" : "Sign Up")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                authViewModel.isFormButtonEnabled ? .black: .black.opacity(0.5)
            )
            .cornerRadius(10)
        }
        .disabled(!authViewModel.isFormButtonEnabled)
    }
    
    private var errorMessageView: some View {
        Group {
            if case .failed(let error) = authViewModel.authState {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }
        }
    }
    
    private var modeToggleButton: some View {
        HStack {
            Text(authViewModel.mode == .signIn ? "Don't have an account?" : "Already have an account?")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            Button(authViewModel.mode == .signIn ? "Sign up" : "Sign in") {
                withAnimation(.snappy) {
                    authViewModel.toggleMode()
                }
            }
            .foregroundColor(.blue)
            .font(.subheadline)
        }
        .padding(.bottom, 40)
    }
    
    private var passwordValidationList: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(authViewModel.passwordValidationStatus, id: \.requirement) { status in
                HStack(spacing: 4) {
                    Image(systemName: status.isSatisfied ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(status.isSatisfied ? .green : .gray)
                        .font(.caption2)
                    Text(status.requirement)
                        .font(.caption)
                        .foregroundStyle(status.isSatisfied ? .green : .gray)
                }
                .animation(.easeInOut, value: status.isSatisfied)
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
