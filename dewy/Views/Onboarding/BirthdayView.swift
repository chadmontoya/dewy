import SwiftUI

struct BirthdayView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    var body: some View {
        VStack {
            Text("enter your birthday")
                .padding()
                .font(.title)
                .bold()
                .foregroundStyle(Color.coffee)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Text("Date of Birth")
                .font(.footnote)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.gray)
            
            Button {
                
            } label: {
                Text(onboardingVM.birthday.formatted(date: .numeric, time: .omitted))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.gray)
                    .background(.white)
            }
            .cornerRadius(10)
            .padding(.bottom)
            
            
            NavigationLink {
                UserLocationView()
                    .environmentObject(onboardingVM)
                    .toolbarRole(.editor)
            } label: {
                Text("Next")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(Color.coffee)
            }
            .cornerRadius(10)
            
            Spacer()
            
            DatePicker("", selection: $onboardingVM.birthday, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .colorScheme(.light)
                .padding()
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cream)
    }
}
