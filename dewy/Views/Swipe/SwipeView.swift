import SwiftUI

struct SwipeView: View {
    @State private var showPreferences = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()
                
                ForEach(0 ..< 10) { card in
                    CardView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPreferences = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(Color.coffee)
                    }
                }
            }
            .fullScreenCover(isPresented: $showPreferences) {
                PreferencesView(showPreferences: $showPreferences)
            }
        }
    }
}
