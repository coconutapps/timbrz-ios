import SwiftUI
import MapKit

final class ListingAnnotation: NSObject, MKAnnotation {
    let listing: Listing
    init(listing: Listing) {
        self.listing = listing
    }
    var coordinate: CLLocationCoordinate2D { listing.coordinate }
    var title: String? { listing.title }
    var subtitle: String? { "$\(listing.price.formatted(.currency(code: "USD"))) • \(listing.types.propertyType)" }
}

struct MapViewRepresentable: UIViewRepresentable {
    var listings: [Listing]
    @Binding var selected: Listing?
    var showsUserLocation: Bool = true

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.pointOfInterestFilter = .includingAll
        map.showsUserLocation = showsUserLocation
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        map.userTrackingMode = .none
        map.showsCompass = true
        map.showsScale = true
        map.showsBuildings = true
        map.isRotateEnabled = true
        map.isPitchEnabled = true
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let existing = uiView.annotations.compactMap { $0 as? ListingAnnotation }
        uiView.removeAnnotations(existing)
        let annotations = listings.map { listing -> ListingAnnotation in
            ListingAnnotation(listing: listing)
        }
        uiView.addAnnotations(annotations)
        if uiView.annotations.isEmpty == false && uiView.region.span.latitudeDelta == 0 {
            uiView.showAnnotations(uiView.annotations, animated: false)
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        init(_ parent: MapViewRepresentable) { self.parent = parent }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: cluster) as! MKMarkerAnnotationView
                view.clusteringIdentifier = "cluster"
                view.displayPriority = .defaultHigh
                view.titleVisibility = .visible
                view.subtitleVisibility = .adaptive
                view.canShowCallout = true
                view.glyphText = "\(cluster.memberAnnotations.count)"
                view.markerTintColor = .systemTeal
                view.accessibilityLabel = "\(cluster.memberAnnotations.count) listings in this area"
                return view
            }
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation) as! MKMarkerAnnotationView
            view.clusteringIdentifier = "cluster"
            view.canShowCallout = true
            view.displayPriority = .defaultHigh
            view.animatesWhenAdded = true
            view.glyphImage = UIImage(systemName: "house.fill")
            view.accessibilityLabel = (annotation.title ?? nil) ?? "Listing"
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let ann = view.annotation as? ListingAnnotation {
                parent.selected = ann.listing
            } else if let cluster = view.annotation as? MKClusterAnnotation {
                // Expand cluster: zoom to show clustered members
                let members = cluster.memberAnnotations
                mapView.showAnnotations(members, animated: true)
            }
        }
    }
}
