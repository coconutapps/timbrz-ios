import SwiftUI
import MapKit

struct ListingDetailView: View, Identifiable {
    var id: String { listing.id }
    let listing: Listing
    @State private var expandDescription = false

    var body: some View {
        ScrollView {
            TabView {
                ForEach(listing.media.gallery, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        ZStack { Color.gray.opacity(0.2); ProgressView() }
                    }
                }
            }
            .frame(height: 280)
            .tabViewStyle(.page)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("$\(listing.price.formatted())")
                        .font(.title).bold()
                    Spacer()
                    Button { /* save */ } label { Image(systemName: "heart") }
                    Button { /* share */ } label { Image(systemName: "square.and.arrow.up") }
                }
                Text("\(listing.beds) bd • \(listing.baths, specifier: "%.1f") ba • \(listing.sqft) sqft • \(listing.acres, specifier: "%.1f") ac")
                    .foregroundStyle(.secondary)

                WrapChips(tags: [listing.types.propertyType] + listing.types.buildMaterials + listing.offgrid.power + listing.offgrid.connectivity)

                // Stats row similar to Zillow: days, views, saves
                HStack(spacing: 24) {
                    Label("25 days on Timbrz", systemImage: "calendar")
                        .font(.footnote)
                    VStack(alignment: .leading) {
                        Text("\(listing.viewsCount) views").font(.footnote)
                        Text("\(listing.savesCount) saves").font(.footnote)
                    }
                }
                .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description").font(.headline)
                    Group {
                        if expandDescription {
                            Text(listing.description)
                        } else {
                            Text(listing.description).lineLimit(3)
                        }
                    }
                    Button(expandDescription ? "Show less" : "Show more") { withAnimation { expandDescription.toggle() } }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Map & Nearby").font(.headline)
                    Map(position: .constant(.region(MKCoordinateRegion(center: listing.coordinate, latitudinalMeters: 4000, longitudinalMeters: 4000)))) {
                        Marker(listing.title, coordinate: listing.coordinate)
                    }
                    .frame(height: 200)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Utilities & Access").font(.headline)
                    WrapChips(tags: listing.offgrid.power + listing.offgrid.water + listing.offgrid.waste + listing.offgrid.connectivity)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Outdoor Nearby").font(.headline)
                    WrapChips(tags: listing.outdoors.activities + listing.outdoors.water + listing.outdoors.terrain)
                }
            }
            .padding()
        }
        .navigationTitle(listing.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button { /* call agent */ } label {
                    Text("Call agent")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                Button { /* message agent */ } label {
                    Text("Message agent")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

private struct WrapChips: View {
    var tags: [String]
    var body: some View {
        FlexibleView(data: tags) { tag in
            Text(tag)
                .font(.caption)
                .padding(.vertical, 4).padding(.horizontal, 8)
                .background(Color.secondary.opacity(0.12))
                .clipShape(Capsule())
        }
    }
}

// Simple flexible wrap layout
struct FlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var data: Data
    var content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(self.data, id: \.self) { item in
                content(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > g.size.width { width = 0; height -= d.height }
                        let result = width
                        if item == self.data.last { width = 0 } else { width -= d.width }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == self.data.last { height = 0 }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async { binding.wrappedValue = geo.size.height }
            return .clear
        }
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { ListingDetailView(listing: Listing.samples[0]) }
    }
}
