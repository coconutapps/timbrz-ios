import SwiftUI
import MapKit

struct CreateListingWizard: View {
    enum Step: Int, CaseIterable { case basics, property, structures, outdoors, utilities, media, preview }
    @State private var step: Step = .basics

    @State private var title: String = ""
    @State private var price: String = ""
    @State private var coordinate = CLLocationCoordinate2D(latitude: 44.06, longitude: -121.31)

    var body: some View {
        NavigationStack {
            VStack {
                ProgressView(value: Double(step.rawValue + 1), total: Double(Step.allCases.count))
                    .padding()

                content

                HStack {
                    Button("Back") { if let prev = Step(rawValue: step.rawValue - 1) { step = prev } }
                        .disabled(step == .basics)
                    Spacer()
                    Button(step == .preview ? "Publish" : "Next") {
                        if step == .preview { /* publish */ } else if let next = Step(rawValue: step.rawValue + 1) { step = next }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Create Listing")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .basics:
            Form {
                TextField("Title", text: $title)
                TextField("Price (USD)", text: $price).keyboardType(.numberPad)
                Toggle("STR allowed", isOn: .constant(true))
            }
        case .property:
            Form {
                Stepper("Bedrooms: 2", value: .constant(2))
                Stepper("Bathrooms: 1.5", value: .constant(2))
                Stepper("Sqft: 900", value: .constant(900))
                Stepper("Acres: 1.8", value: .constant(2))
            }
        case .structures:
            Form {
                Text("Select structure types and materials")
                Toggle("Cabin", isOn: .constant(true))
                Toggle("Straw-bale", isOn: .constant(true))
                Toggle("Timber frame", isOn: .constant(false))
            }
        case .outdoors:
            Form {
                Text("Activities & Water within distance")
                Toggle("Lakefront", isOn: .constant(true))
                Toggle("Hiking nearby", isOn: .constant(true))
                Slider(value: .constant(10), in: 1...50, step: 1) { Text("Distance (mi)") }
            }
        case .utilities:
            Form {
                Toggle("Solar", isOn: .constant(true))
                Toggle("Well", isOn: .constant(true))
                Toggle("Septic", isOn: .constant(true))
                Toggle("Starlink OK", isOn: .constant(true))
            }
        case .media:
            VStack(spacing: 12) {
                Text("Upload photos, floorplans, 360s").font(.headline)
                RoundedRectangle(cornerRadius: 8).stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .frame(height: 140)
                    .overlay(Text("Drop or select files (stub)"))
                Map(position: .constant(.region(MKCoordinateRegion(center: coordinate, latitudinalMeters: 4000, longitudinalMeters: 4000))))
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(Text("Long-press to drop pin (stub)").padding(6), alignment: .bottom)
            }
            .padding()
        case .preview:
            VStack(alignment: .leading, spacing: 12) {
                Text("Preview").font(.headline)
                ListingCard(listing: Listing.samples[0])
            }
            .padding()
        }
    }
}

struct CreateListingWizard_Previews: PreviewProvider {
    static var previews: some View { CreateListingWizard() }
}
