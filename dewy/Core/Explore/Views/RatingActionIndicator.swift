import SwiftUI

struct RatingActionIndicator: View {
    @Binding var xOffset: CGFloat
    @Binding var yOffset: CGFloat
    let screenCutoff: CGFloat
    
    var body: some View {
        ZStack {
            HStack {
                RatingStamp(number: 3, color: Color(.systemGreen))
                    .opacity(Double(xOffset / screenCutoff))
                
                Spacer()
                
                RatingStamp(number: 2, color: Color(.systemOrange))
                    .opacity(Double(xOffset / screenCutoff) * -1)
            }
            .padding(40)
            
            VStack {
                RatingStamp(number: 1, color: Color(.systemRed))
                    .opacity(Double(yOffset / screenCutoff))
                
                Spacer()
                
                RatingStamp(number: 4, color: Color(.systemBlue))
                    .opacity(Double(yOffset / screenCutoff) * -1)
            }
            .padding(40)
        }
    }
}

struct RatingStamp: View {
    let number: Int
    let color: Color
    
    var body: some View {
        Text("\(number)")
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 75, height: 75)
            .background(color)
            .clipShape(Circle())
    }
}
