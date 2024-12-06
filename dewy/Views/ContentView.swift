import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            if !isTextFieldFocused {
                // Miscellaneous content above
                VStack {
                    Text("Miscellaneous Content")
                        .font(.headline)
                        .padding()
                }
                .transition(.move(edge: .top))
            }

            Spacer()

            // TextField that moves up when focused
            TextField("Enter something", text: $text)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .padding()
                .animation(.easeInOut, value: isTextFieldFocused)

            Spacer()

            if isTextFieldFocused {
                // Optional: Placeholder for results section
                VStack {
                    Text("Results go here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .transition(.opacity)
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            hideKeyboard()
            isTextFieldFocused = false
        }
        .animation(.easeInOut, value: isTextFieldFocused) // Animate layout changes
    }
}

