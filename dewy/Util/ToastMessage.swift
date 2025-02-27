import SwiftUI

struct ToastMessage: View {
    let iconName: String
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
            Text(message)
        }
        .padding()
        .background(Color.black)
        .foregroundStyle(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
