import SwiftUI

struct BirthdayView: View {
    @EnvironmentObject var onboardingData: OnboardingData
    
    var body: some View {
        VStack {
            Text("What is your age?")
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
                Text(onboardingData.birthday.formatted(date: .numeric, time: .omitted))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.gray)
                    .background(.white)
            }
            .cornerRadius(10)
            .padding(.bottom)
            
            
            NavigationLink {
                LocationView()
                    .environmentObject(onboardingData)
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
            
            DatePicker("", selection: $onboardingData.birthday, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .colorScheme(.light)
                .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cream)
    }
}
