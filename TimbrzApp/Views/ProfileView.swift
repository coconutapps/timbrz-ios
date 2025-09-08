import SwiftUI

struct ProfileView: View {
    @State private var name: String = "Alex Timber"
    @State private var role: String = "buyer"
    @State private var myProperties: [Listing] = Listing.samples.filter { $0.ownerId == "usr-lee" }
    private var versionBuild: String {
        let v = Bundle.main.releaseVersionNumber ?? "1.0"
        let b = Bundle.main.buildVersionNumber ?? "1"
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

                // My Properties management
                Section(header: Text("My properties"), footer: Text("Manage properties you own or represent. Drafts are private until published.")) {
                    if myProperties.isEmpty {
                        Text("No properties yet").foregroundColor(.secondary)
                    } else {
                        ForEach(myProperties, id: \.id) { listing in
                            NavigationLink(destination: PropertyEditorView(listing: listing)) {
                                VStack(alignment: .leading) {
                                    Text(listing.title).font(.body)
                                    Text("$\(listing.price, specifier: "%.0f") • \(listing.beds) bd • \(listing.baths, specifier: "%.1f") ba • \(listing.sqft) sqft")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete { indices in myProperties.remove(atOffsets: indices) }
                    }
                    Button {
                        // Append a lightweight draft example
                        let draft = Listing(
                            id: "draft-\(UUID().uuidString.prefix(6))",
                            title: "New Draft Listing",
                            description: "Describe your property...",
                            price: 0, beds: 0, baths: 0, sqft: 0, acres: 0,
                            yearBuilt: 0, hoa: nil, zoning: [],
                            types: .init(propertyType: "", buildMaterials: []),
                            outdoors: .init(water: [], terrain: [], activities: []),
                            offgrid: .init(power: [], water: [], waste: [], connectivity: []),
                            geo: .init(lat: 0, lng: 0, geohash: ""),
                            media: .init(coverUrl: "", gallery: [], floorplans: []),
                            ownerId: "usr-lee", status: "draft",
                            createdAt: Date(), updatedAt: Date(),
                            viewsCount: 0, savesCount: 0
                        )
                        myProperties.insert(draft, at: 0)
                    } label: {
                        Label("Add property", systemImage: "plus.circle")
                    }
                }

                Section("Account") {
                    Button("Link Apple ID") {}
                    Button("Link Google") {}
                    Button("Sign out", role: .destructive) {}
                }

                Section("Notifications") {
                    Toggle("New message alerts", isOn: .constant(true))
                    Toggle("Price change alerts", isOn: .constant(true))
                    Toggle("Saved search updates", isOn: .constant(true))
                }

                Section("App settings") {
                    Toggle("Dark Mode", isOn: .constant(false))
                    Picker("Map style", selection: .constant("standard")) {
                        Text("Standard").tag("standard")
                        Text("Satellite").tag("satellite")
                        Text("Hybrid").tag("hybrid")
                    }
                }

                Section("Help & feedback") {
                    Button("Send feedback") {}
                    Button("Report a problem") {}
                }

                Section("Privacy portal") {
                    Button("Download my data") {}
                    Button("Delete my account", role: .destructive) {}
                }

                Section("Legal") {
                    Button("Terms of use") {}
                    Button("Privacy policy") {}
                }
            }
            .navigationTitle("Account")
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

// Simple in-form editor stub for drafts and quick editing
private struct PropertyEditorView: View {
    @State var listing: Listing
    var body: some View {
        Form {
            Section("Basics") {
                TextField("Title", text: Binding(get: { listing.title }, set: { listing.title = $0 }))
                TextField("Price", value: Binding(get: { listing.price }, set: { listing.price = $0 }), format: .number)
                Stepper("Beds: \(listing.beds)", value: Binding(get: { listing.beds }, set: { listing.beds = $0 }), in: 0...20)
                Stepper("Baths: \(listing.baths, specifier: %.1f)", value: Binding(get: { listing.baths }, set: { listing.baths = $0 }), in: 0...20, step: 0.5)
            }
            Section("Location") {
                TextField("Latitude", value: Binding(get: { listing.geo.lat }, set: { listing.geo.lat = $0 }), format: .number)
                TextField("Longitude", value: Binding(get: { listing.geo.lng }, set: { listing.geo.lng = $0 }), format: .number)
            }
            Section("Status") {
                Text(listing.status.capitalized)
            }
        }
        .navigationTitle("Edit Property")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View { ProfileView() }
}
