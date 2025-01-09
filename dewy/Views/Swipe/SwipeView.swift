import SwiftUI

struct SwipeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()
                
                ForEach(0 ..< 100) { card in
                    CardView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(Color.coffee)
                }
            }
        }
    }
}
