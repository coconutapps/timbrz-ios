import SwiftUI
import MapKit

struct ExploreView: View {
    @EnvironmentObject var appState: AppState
    @State private var selected: Listing? = nil
    @State private var listings: [Listing] = Listing.samples
    @State private var searchText: String = ""
    @State private var showingFilters: Bool = false
    @State private var filters = FilterState()
    @State private var sheetHeight: CGFloat = UIScreen.main.bounds.height * 0.40
    @FocusState private var searchFocused: Bool

    private var filtered: [Listing] {
        filters.apply(to: listings)
    }

    var body: some View {
        ZStack(alignment: .top) {
            MapViewRepresentable(listings: filtered, selected: $selected, showsUserLocation: false)
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 8) {
                // Search with embedded filter, 4px radius, grey background
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search location, keyword, or lat/lng", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($searchFocused)
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle").font(.title3)
                    }
                    .accessibilityLabel("Filters")
                }
                .padding(10)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .accessibilityLabel("Search")

                // Floating location/map controls similar to Zillow
                HStack(spacing: 10) {
                    Button(action: { /* recenter */ }) {
                        Image(systemName: "location.fill")
                            .font(.body)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Button(action: { /* draw area */ }) {
                        Image(systemName: "lasso")
                            .font(.body)
                            .padding(10)
                            .background(.ultraThinMaterial)
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
        .overlay(alignment: .bottom) { if !searchFocused { bottomSheet } }
        .onChange(of: searchFocused) { focused in
            if !focused { withAnimation(.easeInOut(duration: 0.2)) { sheetHeight = UIScreen.main.bounds.height * 0.40 } }
        }
    }

    // MARK: - Bottom draggable results
    private var bottomSheet: some View {
        let minH: CGFloat = 100
        let maxH: CGFloat = UIScreen.main.bounds.height * 0.85
        let header: some View = HStack(spacing: 8) {
            Text("\(filtered.count) results").font(.headline)
            Spacer(minLength: 8)
            Button(action: { withAnimation { appState.selectedTab = 1 } }) { Label("List", systemImage: "list.bullet") }
                .buttonStyle(.borderless)
        }
        return VStack(spacing: 4) {
            Capsule().fill(Color.secondary.opacity(0.35)).frame(width: 36, height: 4)
                .padding(.top, 2)
            header
                .padding(.horizontal, 12)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filtered) { l in
                        VStack(alignment: .leading, spacing: 6) {
                            Rectangle().fill(Color.secondary.opacity(0.2)).frame(width: 220, height: 120).overlay(Text(l.title).font(.caption).foregroundColor(.secondary))
                            Text(l.title).font(.subheadline).bold()
                            Text("$\(l.price, specifier: "%.0f")").font(.footnote).foregroundColor(.secondary)
                        }
                        .frame(width: 220)
                        .padding(8)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture { selected = l }
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
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .preferredColorScheme(.dark)
    }
}
