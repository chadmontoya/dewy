import Supabase
import SwiftUI

enum TabSelection: Hashable {
    case home
    case saved
    case closet
    case profile
}

struct HomeView: View {
    @EnvironmentObject var authController: AuthController
    
    @State private var currentTab: TabSelection = .home
    @State private var uploadOutfit: Bool = false
    @State private var navigationPath: [String] = []
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = .gray
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView(selection: $currentTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    SwipeView()
                }
                
                Tab("Saved", systemImage: "questionmark.circle.fill", value: .saved) {
                }
                
                Tab("Closet", systemImage: "questionmark.circle.fill", value: .closet) {
                    ClosetView(uploadOutfit: $uploadOutfit)
                }
                
                Tab("Profile", systemImage: "person.circle.fill", value: .profile) {
                    ZStack {
                        Color.cream.ignoresSafeArea()
                        VStack {
                            Text("hello, \(authController.session?.user.email ?? "no email")").foregroundStyle(.black)
                            
                            Button("sign out", role: .destructive) {
                                Task {
                                    try await supabase.auth.signOut()
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $uploadOutfit) {
                UploadOutfitView(onComplete: {
                    uploadOutfit = false
                    navigationPath.removeAll()
                })
                .toolbarRole(.editor)
            }
        }
    }
}
