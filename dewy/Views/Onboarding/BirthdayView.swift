import SwiftUI

struct BirthdayView: View {
    @StateObject private var vm = OnboardingViewModel()
    @Environment(AuthController.self) var auth
    
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
                Text(vm.birthday.formatted(date: .numeric, time: .omitted))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.gray)
                    .background(.white)
            }
            .cornerRadius(10)
            .padding(.bottom)
            
            
            NavigationLink {
                LocationView()
                    .environmentObject(vm)
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
            
            DatePicker("", selection: $vm.birthday, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .colorScheme(.light)
                .padding()
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cream)
        .onAppear {
            print(auth.currentUserId)
        }
    }
}
