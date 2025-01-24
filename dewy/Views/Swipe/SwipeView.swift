import SwiftUI

struct SwipeView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var preferencesVM: PreferencesViewModel
    
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
                PreferencesView(preferencesVM: preferencesVM, showPreferences: $showPreferences)
            }
        }
        .onAppear {
            if let userId = authController.session?.user.id {
                Task {
                    try await preferencesVM.fetchPreferences(userId: userId)
                }
            }
        }
    }
}
