import SwiftUI

struct ProfileViewWIP: View {
    @State private var selectedTab = 0
    @State private var currentXOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 30) {
                Spacer()
                
                TabBarButton(text: "First", isSelected: selectedTab == 0)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 0
                        }
                    }
                
                TabBarButton(text: "Second", isSelected: selectedTab == 1)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 1
                        }
                    }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            // Tab Content
            TabView(selection: $selectedTab) {
                FirstView()
                    .tag(0)
                
                SecondView()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let screenWidth = UIScreen.main.bounds.width
                        let progress = value.translation.width / screenWidth
                        currentXOffset = -progress * (70 + 30) // buttonWidth + spacing
                    }
                    .onEnded { _ in
                        currentXOffset = 0
                    }
            )
        }
    }
}

struct TabBarButton: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(text)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .blue : .gray)
            
            // Underline
            Rectangle()
                .fill(isSelected ? Color.blue : Color.clear)
                .frame(width: 30, height: 2)
        }
        .frame(width: 70)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// Example Views
struct FirstView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
            Text("First View")
        }
    }
}

struct SecondView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
            Text("Second View")
        }
    }
}

// Preview
struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileViewWIP()
    }
}
