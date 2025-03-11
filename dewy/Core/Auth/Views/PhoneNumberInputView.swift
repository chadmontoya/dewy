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
                    TextField("", text: .constant("\(authViewModel.countryCode) \(authViewModel.phoneNumberExtension)"))
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
                                Divider()
                                    .background(.black)
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
                            Divider()
                                .background(.black)
                        }
                    )
                    .focused($showKeyboard)
            }
            
            Text("We'll text a verification code to your phone to verify your identity. Message and data rates may apply.")
                .font(.footnote)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            NavigationLink {
                VerifyCodeView(authViewModel: authViewModel)
                    .toolbarRole(.editor)
            } label: {
                Text("Send Code")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!authViewModel.phoneNumber.isEmpty ? .black : .black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(authViewModel.phoneNumber.isEmpty)
            .simultaneousGesture(TapGesture().onEnded {
                Task {
//                    await authViewModel.sendPhoneVerification()
                }
            })
        }
        .padding()
        .background(Color.primaryBackground.ignoresSafeArea())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            showKeyboard = true
        }
    }
}
