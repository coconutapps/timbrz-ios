# Accessibility checklist (iOS)

- Dynamic Type: use system fonts; test XL–XXXL.
- Contrast: meet WCAG AA for text/icons in light/dark.
- VoiceOver: labels on map pins, clusters (e.g., "12 listings in this area"), chips, and cards.
- Map interactions: provide alternative list navigation for screen reader users; ensure focus order.
- Hit targets: 44x44pt minimum for pins, chips, buttons.
- Reduce motion: respect Reduce Motion for clustering animations and sheet transitions.
- Images: provide accessibility labels for hero images when informative; otherwise mark as decorative.
- Errors: announce validation errors; inline hints for forms.
- Haptics: subtle feedback on save/favorite and map gestures (optional, respect settings).
- Localization: prepare strings for localization; avoid hard-coded.
