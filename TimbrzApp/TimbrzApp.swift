import SwiftUI

@main
struct TimbrzApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
        }
    }
}

final class AppState: ObservableObject {
    @Published var offline: Bool = false
    @Published var selectedTab: Int = 0
}

struct RootTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash: Bool = true

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "map") }
                .tag(0)

            BrowseView()
                .tabItem { Label("Browse", systemImage: "list.bullet") }
                .tag(1)

            SavedView()
                .tabItem { Label("Saved", systemImage: "heart") }
                .tag(2)

            CreateListingWizard()
                .tabItem { Label("Create", systemImage: "plus.square.on.square") }
                .tag(3)

            MessagesView()
                .tabItem { Label("Messages", systemImage: "bubble.left.and.bubble.right") }
                .tag(4)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(5)
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackgroundVisibility(.visible, for: .tabBar)
        .overlay(alignment: .top) {
            if appState.offline {
                Text("Offline — showing cached results")
                    .font(.footnote)
                    .padding(8)
                    .background(.ultraThickMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
        }
        .overlay {
            if showSplash {
                SplashView(isFinished: $showSplash)
            }
        }
    }
}
