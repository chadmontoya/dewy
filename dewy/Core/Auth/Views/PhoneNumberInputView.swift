import SwiftUI

struct PhoneNumberInputView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your phone number")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
            
            HStack(spacing: 10) {
                Button(action: {
                    authViewModel.isCountryCodeSheetPresented = true
                }) {
                    TextField("", text: .constant("\(authViewModel.countryCode) +\(authViewModel.phoneNumberExtension)"))
                        .disabled(true)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .overlay(alignment: .trailing) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                                .padding(.trailing, 4)
                        }
                        .padding(.vertical, 8)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(authViewModel.sendPhoneOTPError != nil ? .red : .black)
                            }
                        )
                        .frame(width: 100)
                }
                .sheet(isPresented: $authViewModel.isCountryCodeSheetPresented) {
                    Text("hello world")
                }
                
                TextField("", text: $authViewModel.phoneNumber, prompt: Text(""))
                    .foregroundStyle(.black)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .padding(.vertical, 8)
                    .background(
                        VStack {
                            Spacer()
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(authViewModel.sendPhoneOTPError != nil ? .red : .black)
                        }
                    )
                    .focused($showKeyboard)
                    .onChange(of: authViewModel.phoneNumber) { _, _ in
                        if authViewModel.sendPhoneOTPError != nil {
                            authViewModel.sendPhoneOTPError = nil
                        }
                    }
            }
            
            if let error = authViewModel.sendPhoneOTPError {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text("We'll text a verification code to your phone to verify your identity. Message and data rates may apply.")
                .font(.footnote)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button(action: {
                showKeyboard = false
                Task {
                    await authViewModel.sendPhoneVerification()
                }
            }) {
                Text("Send Code")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!authViewModel.phoneNumber.isEmpty ? .black : .black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            }
            .disabled(authViewModel.phoneNumber.isEmpty)
        }
        .padding()
        .background(Color.primaryBackground.ignoresSafeArea())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationDestination(isPresented: $authViewModel.navigateToVerify) {
            VerifyCodeView(authViewModel: authViewModel)
                .toolbarRole(.editor)
        }
        .onAppear {
            showKeyboard = true
        }
    }
}
