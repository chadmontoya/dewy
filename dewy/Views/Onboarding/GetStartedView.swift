import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    @Environment(AuthController.self) var auth

    var body: some View {
        VStack {
            Text("thank you")
                .padding()
                .font(.title)
                .bold()
                .foregroundStyle(Color.coffee)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button {
                Task {
                    print("hello world")
                }
            } label: {
                Text("Get Started")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(Color.coffee)
            }
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cream)
    }
}
