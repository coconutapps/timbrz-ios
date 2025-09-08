# Timbrz — Low-fidelity wireframes (per screen)

Note: These are top-to-bottom stacks with key components and notes for interactions. Use as blueprint for high-fidelity design.

## A) Onboarding & Permissions
- Header: Timbrz logo + short story
- Cards: brand imagery carousel
- Buttons: "Sign in with Apple", "Google", "Continue with email", "Continue as guest"
- Module: Location permission explainer
- Module: Notifications explainer (saved search alerts)
- Chips grid: Interests (activities, structure styles)
- Footer: Terms/Privacy links

## B) Explore (Map-first)
- Top bar: search pill (place/lat-lng/keyword), filter button, bell, offline indicator
- Quick chips: Near water, Lakefront, Timbered, Skiing, MTB, Kayak
- Map canvas: MapKit with clustering, compass, scale, recenter button; draw-area lasso (toolbar button)
- Marker tap: half-height listing card (photo, title, price, badges)
- Card swipe up: full sheet (carousel, facts, Save, Contact)
- Empty states: no results; offline cached

## C) Browse (List-first)
- Top: search pill + filter button
- Sort row: newest, price, acreage, distance, popularity
- Result list: listing cards (hero image, badges, mini-map chip)
- Pagination: infinite scroll; offline cached list

## D) Listing Detail
- Hero: gallery carousel (photos/video/360)
- Summary bar: price, beds/baths/sqft, acres, city/state, save/share
- Spec chips: property type, build system/materials, off-grid features
- Map section: property pin + nearby overlays (trailheads, ramps, lifts) with clustering
- Sections: Description; Outdoor Nearby (distance-sorted); Utilities & Access; Zoning/HOA; Documents; Agent/Owner panel (Message, Schedule)
- Footer: Similar listings carousel

## E) Create Listing (Wizard)
- Stepper header: Basics → Property → Structures → Outdoors → Utilities → Media → Preview → Publish
- Content per step: forms with validation, photo picker (Firebase Storage)
- Map picker: address search or long-press to set pin
- Preview card & pin; Publish CTA

## F) Saved (Favorites & Searches)
- Segmented tabs: Favorites | Saved Searches | Alerts
- Favorites: grid/list of saved listings
- Saved Search editor: name, area polygon/radius, filters snapshot, push/email toggles

## G) Messages / Inquiries
- Threads list: grouped by listing
- Chat view: messages with sender avatars; quick templates; attachment button

## H) Profile & Settings
- Profile card: photo, name, role
- Preferences: default activities, units, STR visibility
- Account: linked providers, sign-out, delete account

## I) Content (Learn)
- Articles list: cards with hero image; categories
- Article detail: SEO-friendly layout (for web parity)

## J) Admin (internal)
- Queues: Listing approvals; Content flags
- Taxonomy editor: activities, materials
- Feature flags: Remote Config toggles

---

# Component inventory
- App shell: Tab bar; global search pill; filter sheet
- Map: MapViewRepresentable (MKMapView) with clustering; draw lasso (stub)
- Cards: ListingCard, SimilarListingCard
- Controls: Chips (multi-select), Range sliders (price, acres), Toggles (STR allowed), Distance sliders (activities)
- Forms: TextFields with validation, media picker uploader (Storage)
- System affordances: compass, recenter, zoom, rotation, long-press pin
- States: loading skeletons; offline banner; empty results
