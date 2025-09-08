import Foundation

struct FilterState: Equatable {
    // Basics
    var priceMin: Int? = nil
    var priceMax: Int? = nil
    var bedsMin: Int? = nil
    var bathsMin: Double? = nil
    var acresMin: Double? = nil
    var acresMax: Double? = nil
    var yearMin: Int? = nil
    var yearMax: Int? = nil
    var hoaMax: Int? = nil
    var strAllowed: Bool? = nil

    // Facets
    var propertyTypes: Set<String> = []
    var buildMaterials: Set<String> = []
    var water: Set<String> = []
    var terrain: Set<String> = []
    var activities: Set<String> = []

    mutating func reset() { self = FilterState() }
}

extension FilterState {
    // Catalogs
    static let priceSteps: [Int] = [50000, 100000, 150000, 200000, 300000, 400000, 500000, 650000, 800000, 1000000]
    static let acresSteps: [Double] = [0.25, 0.5, 1, 2, 5, 10, 20, 40, 80, 160]
    static let yearSteps: [Int] = [1970, 1980, 1990, 2000, 2010, 2015, 2020, 2024]
    static let bedsSteps: [Int] = [0,1,2,3,4,5]
    static let bathsSteps: [Double] = [0,1,1.5,2,2.5,3]

    static let propertyTypeOptions: [String] = [
        "tiny","cabin","cottage","a-frame","park-model-rv","yurt","dome","tent","treehouse","earth-sheltered","container","manufactured","modular","stick-built","barndominium","shed-to-home","boat-house","floating-home"
    ]
    static let buildMaterialOptions: [String] = [
        "earthbag","straw-bale","cob","adobe","rammed earth","cordwood","hempcrete","bamboo","timber frame","log","stone","passive solar","green-roof","high-r-value"
    ]
    static let waterOptions: [String] = [
        "oceanfront","lakefront","riverfront","creek/stream","pond","wetland","seasonal stream","waterfall","dock","boat ramp"
    ]
    static let terrainOptions: [String] = [
        "timbered","meadow","ridge","bluff/cliff","canyon","valley","prairie/steppe","alpine","desert","coastal dune","island","peninsula"
    ]
    static let activityOptions: [String] = [
        "hiking","mtb","horseback","xc-ski","moto/ohv","kayak","sup","sailing","power boating","fishing","rafting","downhill-ski","backcountry","snowshoe","rock","bouldering","via ferrata","birding","stargazing","hunting","foraging","campfire","rv pads","glamping"
    ]
}

extension FilterState {
    func apply(to listings: [Listing]) -> [Listing] {
        listings.filter { l in
            if let v = priceMin, l.price < v { return false }
            if let v = priceMax, l.price > v { return false }
            if let v = bedsMin, l.beds < v { return false }
            if let v = bathsMin, l.baths < v { return false }
            if let v = acresMin, l.acres < v { return false }
            if let v = acresMax, l.acres > v { return false }
            if let v = yearMin, l.yearBuilt < v { return false }
            if let v = yearMax, l.yearBuilt > v { return false }
            if let v = hoaMax, let hoa = l.hoa, hoa > v { return false }

            if propertyTypes.isEmpty == false && propertyTypes.contains(l.types.propertyType) == false { return false }
            if buildMaterials.isEmpty == false && buildMaterials.intersection(Set(l.types.buildMaterials)).isEmpty { return false }
            if water.isEmpty == false && water.intersection(Set(l.outdoors.water)).isEmpty { return false }
            if terrain.isEmpty == false && terrain.intersection(Set(l.outdoors.terrain)).isEmpty { return false }
            if activities.isEmpty == false && activities.intersection(Set(l.outdoors.activities)).isEmpty { return false }

            if let str = strAllowed, str == true {
                // Simple stand-in: treat zoning containing "recreational" as STR-friendly for demo
                if l.zoning.contains("recreational") == false { return false }
            }
            return true
        }
    }
}
