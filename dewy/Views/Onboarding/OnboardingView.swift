import SwiftUI

struct OnboardingView: View {
    @State var birthday: Date
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("How old are you?")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.coffee)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Text("Date of Birth")
                    .font(.footnote)
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.gray)
                
                Button {
                    
                } label: {
                    Text(birthday.formatted(date: .numeric, time: .omitted))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.gray)
                        .background(.white)
                }
                .cornerRadius(10)
                .padding(.bottom)
                
                
                NavigationLink {
                    LocationView()
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
                
                DatePicker("", selection: $birthday, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .colorScheme(.light)
                    .padding()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.cream)
        }
        .tint(Color.coffee)
    }
}

#Preview {
    OnboardingView(birthday: Date())
}
