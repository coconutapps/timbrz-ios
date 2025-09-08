import SwiftUI

struct BrowseView: View {
    @State private var sort: String = "newest"
    private let options = ["newest","price","acreage","distance","popularity"]
    @State private var filters = FilterState()
    @State private var showingFilters = false

    private var listings: [Listing] { Listing.samples }
    private var filtered: [Listing] { filters.apply(to: listings) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Menu {
                        ForEach(options, id: \.self) { opt in
                            Button(action: { sort = opt }) { Text(opt.capitalized) }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    Spacer()
                    Button(action: { showingFilters = true }) {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                .padding()

                List(filtered) { listing in
                    NavigationLink(value: listing) {
                        ListingCard(listing: listing)
                    }
                }
                .listStyle(.plain)
            }
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
            }
            .navigationTitle("Browse")
            .sheet(isPresented: $showingFilters) {
                FiltersSheetView(filters: $filters, allListingsCount: listings.count) { _ in }
                    .presentationDetents([.large])
            }
        }
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
