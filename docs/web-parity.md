# Web parity plan

- Layout: Zillow-style split — left list, right map. Keep filters on top with collapsible sections.
- Map: MapKit JS or Mapbox GL JS. Implement clustering and draw-area lasso. Maintain same Firestore schema.
- Auth: Firebase Auth (Apple, Google, Email) via web SDK.
- Data: Firestore with identical indexes; Storage for media; FCM via Web Push (if needed) or email for alerts.
- Rendering: Server-rendered list pages (Next.js/Remix) + client-side map hydration. SEO-friendly detail pages with social meta tags (Open Graph/Twitter).
- Accessibility: Keyboard navigation for filters/list; ARIA for map clusters and results announcements.
- Remote Config parity: feature flags consumed by web as well.
- Differences:
  - Map gestures and system controls adapt to web patterns.
  - File upload UI differs; drag/drop supported.
  - Notifications via Web Push optional, fallback to email.
