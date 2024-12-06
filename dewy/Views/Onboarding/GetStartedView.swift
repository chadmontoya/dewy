import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject var onboardingData: OnboardingData
    
    var body: some View {
        VStack {
            Spacer()
            
            NavigationLink {
                HomeView()
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
        .onAppear {
            print(onboardingData.birthday.formatted())
            print(onboardingData.gender.type.rawValue)
            print(onboardingData.location)
        }
    }
}
