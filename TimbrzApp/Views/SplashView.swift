import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool

    private var versionBuild: String {
        let v = Bundle.main.releaseVersionNumber ?? "1.0"
        let b = Bundle.main.buildVersionNumber ?? "1"
        return "v\(v) (\(b))"
    }

    var body: some View {
        ZStack {
            Color(UIColor(red: 0.329, green: 0.725, blue: 0.282, alpha: 1.0)) // #54b948
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()
                // Replace "AppLogo" with your vector PDF in Assets.xcassets
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
            // Hold the splash for 3 seconds, then dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.3)) { isFinished = false }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(isFinished: .constant(false))
    }
}

