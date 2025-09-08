import SwiftUI
import MapKit

final class ListingAnnotation: NSObject, MKAnnotation {
    let listing: Listing
    init(listing: Listing) {
        self.listing = listing
    }
    var coordinate: CLLocationCoordinate2D { listing.coordinate }
    var title: String? { listing.title }
    var subtitle: String? { "\(listing.price.formatted(.currency(code: "USD"))) • \(listing.types.propertyType)" }
}

struct MapViewRepresentable: UIViewRepresentable {
    var listings: [Listing]
    @Binding var selected: Listing?
    var showsUserLocation: Bool = true
    var drawMode: Bool = false
    var onPolygonDrawn: (([CLLocationCoordinate2D]) -> Void)? = nil

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
        // Pan gesture for lasso draw
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        pan.isEnabled = drawMode
        map.addGestureRecognizer(pan)
        context.coordinator.mapView = map
        context.coordinator.pan = pan
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

        // Enable/disable draw gesture based on mode
        context.coordinator.pan?.isEnabled = drawMode
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        weak var mapView: MKMapView?
        var pan: UIPanGestureRecognizer?
        var path: [CLLocationCoordinate2D] = []
        var previewLine: MKPolyline?
        var polygon: MKPolygon?
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

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let pl = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: pl)
                r.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8)
                r.lineWidth = 3
                return r
            } else if let pg = overlay as? MKPolygon {
                let r = MKPolygonRenderer(polygon: pg)
                r.fillColor = UIColor.systemBlue.withAlphaComponent(0.15)
                r.strokeColor = UIColor.systemBlue
                r.lineWidth = 2
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard parent.drawMode, let map = mapView else { return }
            let point = gesture.location(in: map)
            let coord = map.convert(point, toCoordinateFrom: map)

            switch gesture.state {
            case .began:
                path = [coord]
                if let previewLine { map.removeOverlay(previewLine) }
                if let polygon { map.removeOverlay(polygon) }
                previewLine = MKPolyline(coordinates: path, count: path.count)
                if let previewLine { map.addOverlay(previewLine!) }
            case .changed:
                path.append(coord)
                if let previewLine { map.removeOverlay(previewLine) }
                previewLine = MKPolyline(coordinates: path, count: path.count)
                if let previewLine { map.addOverlay(previewLine!) }
            case .ended, .cancelled:
                // Close polygon if we have enough points
                guard path.count > 2 else { cleanupPreview() ; return }
                polygon = MKPolygon(coordinates: path, count: path.count)
                if let previewLine { map.removeOverlay(previewLine) }
                if let polygon { map.addOverlay(polygon!) }
                parent.onPolygonDrawn?(path)
                path.removeAll()
            default:
                break
            }
        }

        private func cleanupPreview() {
            if let map = mapView, let previewLine { map.removeOverlay(previewLine) }
            previewLine = nil
        }
    }
}
