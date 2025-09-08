import SwiftUI

struct SavedView: View {
    @State private var tab: Int = 0 // 0 Favorites, 1 Searches, 2 Alerts

    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $tab) {
                    Text("Favorites").tag(0)
                    Text("Saved Searches").tag(1)
                    Text("Alerts").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                if tab == 0 {
                    List(Listing.samples) { ListingCard(listing: $0) }
                        .listStyle(.plain)
                } else if tab == 1 {
                    List {
                        Text("Lakefront Straw-bale near Trails")
                        Text("A-frames near Ski Lifts")
                    }
                } else {
                    List {
                        Text("New match in A-frames near Ski Lifts")
                        Text("Price drop: Straw-bale Lakefront Cabin")
                    }
                }
            }
            .navigationTitle("Saved")
        }
    }
}

struct SavedView_Previews: PreviewProvider {
    static var previews: some View { SavedView() }
}
