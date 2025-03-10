import SwiftUI

struct PhoneSignInButton: View {
    var body: some View {
        HStack {
            Image(systemName: "phone.fill")
            Text("Sign in with Phone")
                .font(.system(size: 16, weight: .medium))
        }
        .foregroundStyle(.white)
        .frame(width: 300, height: 50)
        .background(.black)
        .clipShape(Capsule())
    }
}
