import SwiftUI

struct ListingCard: View {
    let listing: Listing

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: listing.media.coverUrl)) { phase in
                switch phase {
                case .empty:
                    ZStack { Color.gray.opacity(0.2); ProgressView() }
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure:
                    ZStack { Color.gray.opacity(0.2); Image(systemName: "photo") }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 110, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title)
                    .font(.headline)
                    .lineLimit(1)
                Text("$\(listing.price.formatted()) • \(listing.beds) bd • \(listing.baths, specifier: "%.1f") ba • \(listing.sqft) sqft")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    ForEach((listing.outdoors.water + listing.outdoors.activities).prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.vertical, 3).padding(.horizontal, 6)
                            .background(Color.secondary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(listing.title), priced at $\(listing.price), \(listing.beds) bedrooms")
    }
}

struct ListingCard_Previews: PreviewProvider {
    static var previews: some View {
        List(Listing.samples) { ListingCard(listing: $0) }
            .listStyle(.plain)
    }
}
