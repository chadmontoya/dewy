import SwiftUI

struct GenderView: View {
    @ObservedObject var preferencesVM: PreferencesViewModel
    @ObservedObject var onboardingVM: OnboardingViewModel
    
    var body: some View {
        VStack {
            Text("select your gender")
                .padding()
                .font(.title)
                .bold()
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Text("Gender")
                .font(.footnote)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.gray)
            
            Button {
                
            } label: {
                Text(onboardingVM.gender.type.rawValue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.gray)
                    .background(.white)
            }
            .cornerRadius(10)
            .padding(.bottom)
            
            NavigationLink {
                GetStartedView(
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
            
            Picker("Gender", selection: $onboardingVM.gender.type) {
                ForEach(Gender.GenderType.allCases, id: \.self) { genderType in
                    Text(genderType.rawValue).tag(genderType)
                }
            }
            .pickerStyle(.wheel)
            .colorScheme(.light)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cream)
    }
}
