import SwiftUI

struct ListingCarouselCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomLeading) {
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
                .frame(width: 280, height: 180)
                .clipped()

                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
                    .frame(height: 70)
                    .frame(maxWidth: .infinity, alignment: .bottom)

                VStack(alignment: .leading, spacing: 2) {
                    Text("$\(listing.price.formatted())")
                        .font(.headline).bold()
                        .foregroundColor(.white)
                    Text("\(listing.beds) bd • \(listing.baths, specifier: "%.1f") ba • \(listing.acres, specifier: "%.1f") ac")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(10)
            }
            Text(listing.title)
                .font(.subheadline)
                .lineLimit(1)
        }
        .frame(width: 280)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

struct ListingCarouselCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack { ForEach(Listing.samples) { ListingCarouselCard(listing: $0) } }
                .padding()
        }
        .frame(height: 260)
    }
}
