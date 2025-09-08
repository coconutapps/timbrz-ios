import SwiftUI

struct ProfileView: View {
    @State private var name: String = "Alex Timber"
    @State private var role: String = "buyer"
    private var versionBuild: String {
        let v = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
        let b = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
        return "v\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    HStack { Circle().fill(.gray).frame(width: 48, height: 48); TextField("Name", text: $name) }
                    Picker("Role", selection: $role) {
                        Text("Buyer").tag("buyer")
                        Text("Seller").tag("seller")
                        Text("Agent").tag("agent")
                    }
                }

                Section("Preferences") {
                    Toggle("Show STR-friendly listings", isOn: .constant(true))
                    Picker("Units", selection: .constant("imperial")) {
                        Text("Imperial").tag("imperial")
                        Text("Metric").tag("metric")
                    }
                    Text("Default activities")
                    HStack { Chip("Hiking"); Chip("Kayak"); Chip("MTB") }
                }

                Section("Account") {
                    Button("Link Apple ID") {}
                    Button("Link Google") {}
                    Button("Sign out", role: .destructive) {}
                }
            }
            .navigationTitle("Profile")
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 8) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .accessibilityHidden(true)
                    Text("Timbrz \(versionBuild)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
}

private struct Chip: View { let text: String; init(_ t: String){ text = t }
    var body: some View {
        Text(text).font(.caption).padding(.vertical, 4).padding(.horizontal, 8)
            .background(Color.secondary.opacity(0.12)).clipShape(Capsule())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View { ProfileView() }
}
