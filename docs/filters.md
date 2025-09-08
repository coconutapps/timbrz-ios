# Filters catalog (facets and schema keys)

Use these as structured facets on `listings` schema. Keys map to `firestore-schema.md`.

- Environment / Water / Terrain
  - Key: `outdoors.water`
    - Values: oceanfront, lakefront, riverfront, creek/stream, pond, wetland, seasonal stream, waterfall, dock/slip, boat ramp
  - Key: `outdoors.terrain`
    - Values: timbered, meadow, ridge, bluff/cliff, canyon, valley, prairie/steppe, alpine, desert, coastal dune, island, peninsula
  - Key: `views`
    - Values: ocean, lake, mountain, forest, sky
  - Key: `elevationBand`, `slope`, `aspect` (numerical/range)

- Activities (nearby within distance sliders)
  - Key: `outdoors.activities`
    - Trails: hiking, mountain biking, horseback, xc skiing, moto/ohv
    - Water: kayaking/canoeing, sup, sailing, power boating, fishing, rafting
    - Snow: downhill skiing, backcountry, snowshoe
    - Climb: rock, bouldering, via ferrata
    - Wildlife & nature: birding, stargazing, hunting, foraging
    - Family/camp: campfire ring allowed, rv pads, glamping amenities
  - Distance per category: `activitiesDistance.{type}` in miles

- Structure type (what it is)
  - Key: `types.propertyType`
    - Values: tiny house, cabin, cottage, a-frame, park model rv, yurt, dome, tent/safari tent, treehouse, earth-sheltered, container, manufactured, modular, stick-built, barndominium, shed-to-home, boat house, floating home

- Build system / Materials (how it’s built)
  - Key: `types.buildMaterials`
    - Natural building: earthbag, straw-bale, cob, adobe, rammed earth, cordwood, hempcrete, bamboo, timber frame, log, stone
    - Green features: passive solar, sod/green roof, high r-value envelope

- Utilities / Off-grid
  - Keys: `offgrid.power`, `offgrid.water`, `offgrid.waste`, `offgrid.connectivity`, `access`
    - Power: grid, solar pv, micro-hydro, wind, generator backup
    - Water: municipal, well, spring, rain catchment; treatment options
    - Waste: sewer, septic, composting toilet, graywater
    - Connectivity: fiber, cable, lte/5g quality sliders, starlink friendly
    - Access: year-round plowed, 4x4 seasonal, private road, easements

- Property basics
  - price: min/max
  - bedrooms: min/max
  - baths: min/max
  - interior sqft: min/max
  - lot acres: min/max
  - year built / renovated: range
  - hoa dues: max
  - zoning: `zoning[]` (recreational, ag, timber, mixed-use)
  - STR permitted: boolean

Notes:
- For numeric sliders use inclusive ranges and remember Firestore index constraints for compound order-by.
- Store polygons/radii in SavedSearch geometry for spatial filters.
