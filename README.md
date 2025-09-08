# Timbrz — Outdoor-forward property discovery

Timbrz is a Zillow-style discovery app for cabins, tiny homes, yurts, and alternative builds, optimized for outdoor enthusiasts.

This repository contains:

- Docs: sitemap, user flows, low-fi wireframes, Firestore schema & rules, sample queries, a11y checklist, web parity notes.
- iOS SwiftUI stubs: Tabbed app skeleton, MapKit wrapper with clustering, screen stubs, models, and realistic sample data.

## UX & Tech Guardrails (iOS)

- UI: SwiftUI, MapKit.
- Navigation: bottom `TabView`. Global search pill, filter button, chips, notifications bell, offline indicator.
- Maps: clustering for dense areas with count bubbles, smooth zoom, Apple HIG gestures (pinch/rotate/compass/recenter), draw-area lasso (stub), long-press drop pin.
- Sheets: tappable markers open half-height listing card; swipe to full sheet.
- Accessibility: Dynamic Type, Dark Mode, VoiceOver labels on pins/cards, large hit targets.
- Performance: lazy loading, async images, Firestore offline persistence.

## Firebase

- Auth: Email, Apple, Google (partner custom tokens later).
- Firestore: primary store; offline persistence; geoqueries by geohash + viewport bounds.
- Storage: photos, floorplans, 360s; auth required.
- FCM: saved-search alerts; Remote Config for feature flags.

## Structure

- `docs/` — design docs and diagrams
- `TimbrzApp/` — SwiftUI app skeleton
  - `Views/` Explore, Browse, ListingDetail, Create Listing, Saved, Messages, Profile
  - `Map/` MapKit representable with clustering
  - `Models/` Listing, UserProfile, SavedSearch
  - `Services/` FirebaseService (stubs), GeoQueryService (stubs)
  - `SampleData/` mock JSON for listings and POIs

Note: The single source of truth for app source files is `TimbrzApp/` at the repository root. The asset catalog lives at `Timbrz/Timbrz/Assets.xcassets/` (Xcode’s default project folder). Remove any nested duplicate `Timbrz/Timbrz/TimbrzApp/` references from the Xcode target to avoid confusion.

## Build (iOS)

- Open the Xcode project when created; these are stubs to integrate.
- SwiftUI targets iOS 16+.
- MapKit is used directly. Firebase calls are stubbed to avoid requiring keys at this stage.

## Next steps

- Wire Firebase config and Firestore models.
- Implement real geoqueries + clustering with Firestore bounds.
- Replace mock data loader with Firestore-backed `ListingsRepository`.
- Implement draw-area lasso and redo-search-in-area.
- Add Remote Config gates for incremental rollout.

## Version and Build Management

This app auto-displays the current marketing version and build number on the splash screen, and supports auto-incrementing the build number on each build via an Xcode Run Script.

### What’s included

- `TimbrzApp/Extensions/Bundle+Version.swift` — exposes `Bundle.main.releaseVersionNumber` and `Bundle.main.buildVersionNumber`.
- `TimbrzApp/Views/SplashView.swift` and the fallback splash in `Timbrz/Timbrz/TimbrzApp/TimbrzApp.swift` render the version/build at the bottom.
- `increment_build_number.sh` at the repo root — increments `CFBundleVersion` using `PlistBuddy`. It prefers the `INFOPLIST_FILE` build setting and has sensible fallbacks.

### How to enable auto-increment in Xcode

1. Ensure your target has both keys defined (either in a concrete Info.plist file or via build settings expansion):
   - `CFBundleShortVersionString` (e.g., `1.0.0`) — can be set via the `MARKETING_VERSION` build setting.
   - `CFBundleVersion` (e.g., `1`) — can be set via the `CURRENT_PROJECT_VERSION` build setting.

   Note: In newer Xcode templates, Info.plist is synthesized. In that case, set `INFOPLIST_FILE` to a concrete plist file to allow the script to update it, or keep using synthesized Info.plist and rely on `CURRENT_PROJECT_VERSION`/`MARKETING_VERSION` build settings in CI. This repo’s script prefers `INFOPLIST_FILE` and will fall back to a best-effort path.

2. Add the Run Script Phase:
   - Xcode → select your target → Build Phases → `+` → New Run Script Phase.
   - Move it before “Compile Sources”.
   - Script:

     ```bash
     "$SRCROOT/increment_build_number.sh"
     ```

3. Make the script executable (one-time):

   ```bash
   chmod +x "$SRCROOT/increment_build_number.sh"
   ```

4. Optional: add `versions.env` to `.gitignore` if you don’t want to commit it.

### How the script locates Info.plist

The script resolves the Info.plist path in this order:

1. `INFOPLIST_FILE` build setting (absolute or relative to `$SRCROOT`).
2. Common guesses at the repo root: `<TARGET_NAME>-Info.plist`, `Info.plist`.
3. As a last resort, the built Info.plist at `$TARGET_BUILD_DIR/$INFOPLIST_PATH` (not ideal for source control updates, but allows CI visibility).

If it can’t find any, the script will exit with an error and instruct you to set `INFOPLIST_FILE`.

### Displaying the version on Splash

Both splash implementations use:

```swift
let v = Bundle.main.releaseVersionNumber ?? "1.0"
let b = Bundle.main.buildVersionNumber ?? "1"
Text("v\(v) (\(b))")
```

No additional configuration is required beyond having the keys present at runtime.
