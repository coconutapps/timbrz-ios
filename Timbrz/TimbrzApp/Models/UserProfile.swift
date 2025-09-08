import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String
    var displayName: String
    var photoURL: URL?
    var role: String // buyer | seller | agent | admin
    var preferences: Preferences

    struct Preferences: Codable {
        var activities: [String]
        var units: String // imperial | metric
        var strVisibility: Bool
    }
}

struct SavedSearch: Identifiable, Codable {
    var id: String
    var name: String
    var geometry: Geometry
    var filters: [String: CodableValue]
    var notify: Notify

    struct Geometry: Codable {
        var type: String // radius | polygon
        var center: Coordinate? // if radius
        var miles: Double?
        var points: [Coordinate]? // if polygon
    }
    struct Coordinate: Codable { var lat: Double; var lng: Double }
    struct Notify: Codable { var push: Bool; var email: Bool }
}

// CodableValue helper to hold arbitrary filter JSON
enum CodableValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case array([CodableValue])
    case object([String: CodableValue])

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self) { self = .bool(b); return }
        if let n = try? c.decode(Double.self) { self = .number(n); return }
        if let s = try? c.decode(String.self) { self = .string(s); return }
        if let arr = try? c.decode([CodableValue].self) { self = .array(arr); return }
        if let obj = try? c.decode([String: CodableValue].self) { self = .object(obj); return }
        throw DecodingError.typeMismatch(CodableValue.self, .init(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .bool(let v): try c.encode(v)
        case .number(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .array(let v): try c.encode(v)
        case .object(let v): try c.encode(v)
        }
    }
}
