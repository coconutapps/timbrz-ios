import SwiftUI
import MapKit

struct ExploreView: View {
    @EnvironmentObject var appState: AppState
    @State private var selected: Listing? = nil
    @State private var listings: [Listing] = Listing.samples
    @State private var searchText: String = ""
    @State private var showingFilters: Bool = false
    @State private var filters = FilterState()
    @State private var isDrawing = false
    @State private var drawnPolygon: [CLLocationCoordinate2D] = []
    @State private var sheetHeight: CGFloat = UIScreen.main.bounds.height * 0.40
    @FocusState private var searchFocused: Bool

    private var filtered: [Listing] {
        let base = filters.apply(to: listings)
        guard drawnPolygon.count >= 3 else { return base }
        return base.filter { pointInPolygon(point: $0.coordinate, polygon: drawnPolygon) }
    }

    var body: some View {
        ZStack(alignment: .top) {
            MapViewRepresentable(
                listings: filtered,
                selected: $selected,
                showsUserLocation: false,
                drawMode: isDrawing,
                onPolygonDrawn: { coords in
                    drawnPolygon = coords
                    isDrawing = false
                }
            )
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 8) {
                // Search field with embedded filter button
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search location, keyword, or lat/lng", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($searchFocused)
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                    }
                    .accessibilityLabel("Filters")
                }
                .padding(10)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .accessibilityLabel("Search")

                // Floating controls
                HStack(spacing: 10) {
                    Button(action: { appState.selectedTab = 1 }) {
                        Image(systemName: "list.bullet")
                            .font(.body)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Button(action: { /* recenter */ }) {
                        Image(systemName: "location.fill")
                            .font(.body)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Button(action: { isDrawing.toggle() }) {
                        Image(systemName: isDrawing ? "lasso.sparkles" : "lasso")
                            .font(.body)
                            .padding(10)
                            .background(isDrawing ? Color.accentColor.opacity(0.25) : .ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Button(action: { /* map style */ }) {
                        Image(systemName: "map")
                            .font(.body)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .sheet(item: $selected, content: { listing in
            ListingDetailView(listing: listing)
                .presentationDetents([.medium, .large])
        })
        .sheet(isPresented: $showingFilters) {
            FiltersSheetView(filters: $filters, allListingsCount: listings.count) { newFilters in
                // already applied via binding; could trigger refresh here if using network
            }
            .presentationDetents([.large])
        }
        .overlay(alignment: .bottom) {
            if !searchFocused { bottomResultsSheet }
        }
        .onChange(of: searchFocused) { focused in
            if !focused {
                withAnimation(.easeInOut(duration: 0.2)) { sheetHeight = UIScreen.main.bounds.height * 0.40 }
            }
        }
    }

    // MARK: - Bottom results slider
    private var bottomResultsSheet: some View {
        let minH: CGFloat = 100 // compact header height
        let maxH: CGFloat = UIScreen.main.bounds.height * 0.85
        let header: some View = HStack(spacing: 8) {
            Text("\(filtered.count) results")
                .font(.headline)
            Spacer(minLength: 8)
            Button(action: {
                searchFocused = false
                withAnimation(.easeInOut) { appState.selectedTab = 1 }
            }) {
                Label("List", systemImage: "list.bullet")
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Show list")
        }
        return VStack(spacing: 4) {
            Capsule().fill(Color.secondary.opacity(0.35)).frame(width: 36, height: 4)
                .padding(.top, 2)
            header
                .padding(.horizontal, 12)
                .padding(.bottom, 0)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filtered) { l in
                        Button(action: { selected = l }) {
                            ListingCarouselCard(listing: l)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
            }
            .frame(height: max(sheetHeight - 56, 0))
            .clipped()
        }
        .frame(maxWidth: .infinity)
        .frame(height: sheetHeight)
        .background(Color(UIColor.systemGray6))
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    let proposed = sheetHeight - value.translation.height
                    sheetHeight = min(max(proposed, minH), maxH)
                }
        )
    }

    // MARK: - Point in polygon (ray casting)
    private func pointInPolygon(point: CLLocationCoordinate2D, polygon: [CLLocationCoordinate2D]) -> Bool {
        var isInside = false
        var j = polygon.count - 1
        for i in 0..<polygon.count {
            let xi = polygon[i].latitude, yi = polygon[i].longitude
            let xj = polygon[j].latitude, yj = polygon[j].longitude
            let intersect = ((yi > point.longitude) != (yj > point.longitude)) &&
            (point.latitude < (xj - xi) * (point.longitude - yi) / ((yj - yi) == 0 ? 1e-12 : (yj - yi)) + xi)
            if intersect { isInside.toggle() }
            j = i
        }
        return isInside
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .preferredColorScheme(.dark)
    }
}
