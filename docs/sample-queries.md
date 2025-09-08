# Sample queries and backend flows

## Viewport query (geohash ranges)
- Compute current map bounds (NE, SW).
- Derive covering geohash boxes for a precision level (e.g., 5-6 chars) that cover the viewport.
- For each box, query Firestore where `geo.geohash` startsWith(box).
- Combine results client-side; de-dupe by id; apply additional filters; paginate by `createdAt` or `price`.

Pseudo-code:
```swift
let boxes = GeoQueryService.coveringGeohashBoxes(bounds: viewport, precision: 6)
for box in boxes {
  Firestore.collection("listings")
    .order(by: "geo.geohash")
    .start(at: [box])
    .end(at: [box + "\uf8ff"]) // prefix match trick
}
```

## Filter example: "Lakefront straw-bale within 10mi of trailhead"
- outdoors.water contains 'lakefront'
- types.buildMaterials array-contains 'straw-bale'
- Distance: compute geohash or use client-side filter with POI haversine distance; or use a Cloud Function / 3rd-party geo index if needed.

Firestore chaining (client-side multiple queries may be needed due to array-contains limitations):
```swift
q = col.whereField("outdoors.water", arrayContains: "lakefront")
      .whereField("types.buildMaterials", arrayContains: "straw-bale")
// Apply viewport geoboxes OR radius filter client-side after fetching candidates in nearby tiles.
```

## Saved search alert flow
1. User saves search with filters + geometry (polygon or radius).
2. Cloud Function `onCreate(listings/{id})` and `onUpdate` evaluates new/changed listing against saved searches.
3. If match, write notification doc and send FCM to affected users.

Pseudocode (Node.js):
```js
exports.onListingChange = functions.firestore
  .document('listings/{id}')
  .onWrite(async (change, ctx) => {
    const after = change.after.data();
    const searches = await db.collectionGroup('savedSearches').get();
    for (const s of searches.docs) {
      if (matchesFilters(after, s.data())) {
        await sendFcmToUser(s.data().ownerId, buildPayload(after, s.data()));
      }
    }
  });
```
