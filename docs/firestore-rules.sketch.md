# Firestore & Storage rules (sketch)

Note: Harden before production. Use custom claims for roles.

## Firestore rules (sketch)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isAdmin() { return isSignedIn() && request.auth.token.admin == true; }

    match /listings/{listingId} {
      allow read: if true; // public browse
      allow create: if isSignedIn();
      allow update, delete: if isAdmin() || (isSignedIn() && request.auth.uid == resource.data.ownerId);
    }

    match /users/{uid} {
      allow read: if isSignedIn() && request.auth.uid == uid;
      allow write: if isSignedIn() && request.auth.uid == uid;
    }

    match /messages/{threadId} {
      allow read, write: if isSignedIn() && request.resource.data.participants.hasAny([request.auth.uid]);
    }

    match /pois/{poiId} {
      allow read: if true;
      allow write: if isAdmin();
    }
  }
}
```

## Storage rules (sketch)
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function isSignedIn() { return request.auth != null; }
    match /listings/{listingId}/{allPaths=**} {
      allow read: if true; // or gate by listing status
      allow write: if isSignedIn(); // tighten to owner or admin
    }
    match /messages/{threadId}/{allPaths=**} {
      allow read, write: if isSignedIn();
    }
  }
}
```

## FCM / Remote Config
- FCM: Only send alerts for saved searches the user owns. Prefer topics per saved search id or direct device tokens via Cloud Functions.
- Remote Config: Feature flags for lasso search, POI overlays, and content modules.
