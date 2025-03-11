import SwiftUI

struct VerifyCodeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Verify code")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Enter the code sent to +19099673503")
                .font(.footnote)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
            
            OTPTextField(code: $authViewModel.verificationCode, numberOfDigits: 6)
            
            Spacer()
            
            Button(action: {
                Task {
                    await authViewModel.verifyOTP()
                }
            }) {
                Text("Verify")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(authViewModel.verificationCode.count < 6)
        }
        .padding()
        .background(Color.primaryBackground.ignoresSafeArea())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct OTPTextField: View {
    @Binding var code: String
    @State var digits: [String]
    @FocusState private var focusedField: Int?
    
    let numberOfDigits: Int
    
    init(code: Binding<String>, numberOfDigits: Int) {
        self._code = code
        self.numberOfDigits = numberOfDigits
        self.digits = Array(repeating: "", count: numberOfDigits)
    }
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfDigits, id: \.self) { index in
                TextField("", text: $digits[index])
                    .keyboardType(.numberPad)
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .background(
                        VStack {
                            Spacer()
                            Divider()
                                .background(.black)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .multilineTextAlignment(.center)
                    .focused($focusedField, equals: index)
                    .tag(index)
                    .onChange(of: digits[index]) { oldValue, newValue in
                        if digits[index].count > 1 {
                            let currentValueList = Array(digits[index])
                            
                            if currentValueList[0] == Character(oldValue) {
                                digits[index] = String(digits[index].suffix(1))
                            } else {
                                digits[index] = String(digits[index].prefix(1))
                            }
                        }
                        
                        if !newValue.isEmpty {
                            if index == numberOfDigits - 1 {
                                focusedField = nil
                            } else {
                                focusedField = (focusedField ?? 0) + 1
                            }
                        } else {
                            focusedField = (focusedField ?? 0) - 1
                        }
                        
                        code = digits.joined()
                    }
            }
            .onAppear {
                self.focusedField = 0
            }
        }
    }
}
