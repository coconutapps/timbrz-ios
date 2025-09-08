import Foundation
import CoreLocation

struct ViewportBounds {
    var ne: CLLocationCoordinate2D
    var sw: CLLocationCoordinate2D
}

struct GeoQueryService {
    // Placeholder: returns geohash prefixes that cover the viewport; real impl would use geohash libs.
    static func coveringGeohashBoxes(bounds: ViewportBounds, precision: Int = 6) -> [String] {
        // Stub: return a single box derived from center
        let centerLat = (bounds.ne.latitude + bounds.sw.latitude) / 2
        let centerLng = (bounds.ne.longitude + bounds.sw.longitude) / 2
        let approx = String(format: "%.2f:%.2f", centerLat, centerLng)
        return [String(approx.prefix(precision))]
    }

    static func distanceMiles(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
        let locA = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let locB = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return locA.distance(from: locB) / 1609.344
    }
}
