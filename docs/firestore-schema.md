# Firestore schema (collections & fields)

## listings (docId)
- title: string
- description: string
- price: number
- beds: number
- baths: number
- sqft: number
- acres: number
- yearBuilt: number
- hoa: number | null
- zoning: string[]
- types: {
  - propertyType: enum('cabin','tiny','cottage','a-frame','park-model-rv','yurt','dome','tent','treehouse','earth-sheltered','container','manufactured','modular','stick-built','barndominium','shed-to-home','boat-house','floating-home')
  - buildMaterials: string[] // e.g., 'straw-bale','hempcrete','timber frame','log','stone'
}
- outdoors: {
  - water: string[] // 'lakefront','riverfront','dock','boat ramp', ...
  - terrain: string[] // 'timbered','meadow','ridge','alpine', ...
  - activities: string[] // 'hiking','mtb','kayak','bc-ski', ...
}
- offgrid: {
  - power: string[] // 'grid','solar','micro-hydro','wind','generator'
  - water: string[] // 'municipal','well','spring','rain-catchment'
  - waste: string[] // 'sewer','septic','compost','graywater'
  - connectivity: string[] // 'fiber','cable','lte-5g:4', 'starlink-ok'
}
- geo: { lat: number, lng: number, geohash: string }
- media: { coverUrl: string, gallery: string[], floorplans: string[] }
- ownerId: string
- status: enum('draft','active','pending','sold')
- createdAt: timestamp
- updatedAt: timestamp
- viewsCount: number
- savesCount: number

Indexes:
- Composite: price+createdAt (sort), acres+price, geo.geohash prefix, savesCount desc.
- Array-contains for facets: types.buildMaterials, outdoors.water, outdoors.activities, outdoors.terrain.

## users (uid)
- profile { displayName, photoURL, role('buyer'|'seller'|'agent'|'admin') }
- preferences { activities[], units('imperial'|'metric'), strVisibility: bool }
- savedLists: string[] // listing ids
- savedSearches: SavedSearch[] (filters JSON + geometry)

## messages (threadId)
- listingId: string
- participants: string[]
- lastMessage: { text, senderId, sentAt }
- createdAt, updatedAt

## pois (optional)
- name, type('trailhead','ramp','lift'), geo{lat,lng,geohash}

Offline:
- Enable persistence; cache listings and saved objects. Reconcile on reconnect via updatedAt.
