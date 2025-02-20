import SwiftUI

struct BirthdayView: View {
    @ObservedObject var preferencesVM: PreferencesViewModel
    @ObservedObject var onboardingVM: OnboardingViewModel
    
    var body: some View {
        VStack {
            Text("enter your birthday")
                .padding()
                .font(.title)
                .bold()
                .foregroundStyle(.black)
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
                UserLocationView(
                    preferencesVM: preferencesVM,
                    onboardingVM: onboardingVM
                )
                .toolbarRole(.editor)
            } label: {
                Text("Next")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(.black)
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
