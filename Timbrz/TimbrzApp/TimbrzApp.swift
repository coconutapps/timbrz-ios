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

            SavedView()
                .tabItem { Label("Saved", systemImage: "heart") }
                .tag(1)

            MessagesView()
                .tabItem { Label("Inbox", systemImage: "tray") }
                .tag(2)

            ProfileView()
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
                .tag(3)
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
                FallbackSplashView(isFinished: $showSplash)
            }
        }
    }
}

// Local fallback splash to avoid build errors if the standalone SplashView file
// hasn't been added to the target yet. Uses the brand brown #b56129 and shows
// the version/build at the bottom. Replace with the dedicated SplashView file
// once it's added to the target.
private struct FallbackSplashView: View {
    @Binding var isFinished: Bool

    private var versionBuild: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(v) (\(b))"
    }

    var body: some View {
        ZStack {
            Color(UIColor(red: 0.329, green: 0.725, blue: 0.282, alpha: 1.0)) // #54b948
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer()
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .accessibilityHidden(true)
                Spacer()
                Text(versionBuild)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.3)) { isFinished = false }
            }
        }
    }
}
