## TweepTracker Vision

TweepTracker is a legacy iOS app that maps selected Twitter users based on
available geo-related information from Twitter APIs and profile data.

The repository is useful as a historical sample combining TwitterKit,
Crashlytics/Fabric setup, map annotations, profile images, list membership, and
geocoding-style lookups.

The goal is to preserve the sample while making SDK age, credentials, location
privacy, and API limitations explicit.

The current focus is:

Priority:

- Preserve the Twitter list-to-map annotation flow
- Keep Fabric/TwitterKit setup documented as legacy
- Avoid committing API keys, tokens, or crash-reporting secrets
- Treat mapped user data as sensitive
- Keep Xcode project manifests checked in and parseable
- Avoid force-unwrapping remote Twitter API fields
- Avoid force-unwrapping remote profile image URLs or decoded image data
- Preserve normalized latitude/longitude order before rendering map annotations
- Require numeric Twitter timeline coordinates before rendering map annotations
- Require successful Twitter login sessions before map navigation
- Popped map controllers invalidate refresh callbacks, cancel visible avatar
  tasks, detach their map delegate, and remove their navigation logo overlay.
- Avoid blocking map setup while waiting to reveal loaded annotations
- Complete Twitter list lookups even when request setup or transport fails
- Complete Twitter timeline coordinate lookups even when responses lack usable
  coordinates
- Complete Twitter profile-image lookups even when no usable image URL is
  returned
- Keep profile image downloads HTTPS-only, bounded, and off the main operation
  queue
- Stream profile images through an incremental size boundary and establish pin
  task ownership before network work starts
- Reject Boolean, non-finite, and out-of-range public tweet coordinates and
  reduce displayed location precision without requesting device authorization
- Validate Twitter response transport metadata before JSON parsing
- Keep profile image transport on the session-based networking API
- Cancel obsolete profile image tasks when map pins are reused
- Release completed profile image tasks without letting stale callbacks clear
  newer per-pin work
- Prevent reused map pins from displaying another Tweep's delayed avatar
- Keep Twitter/Fabric credentials out of tracked plist files
- Avoid hardcoded external upload paths for user coordinates
- Keep placemark fields and device coordinates out of diagnostic logs
- Keep runtime error log privacy explicit by excluding raw Twitter request and
  authentication errors from diagnostic output
- Keep map refresh generation ownership explicit so stale asynchronous results
  cannot replace current annotations or loading UI state
- Keep GitHub Actions aligned with the local Python `make check` baseline
- Keep the legacy SDK compatibility boundary explicit for iOS 8-era project
  settings, Swift 2-era source, vendored binaries, and unverified live APIs

Next priorities:

- Add consent-oriented runtime UX before any future live geolocation feature
- Replace hardcoded supplemental handles with configurable demo data
- Modernize Swift only in a dedicated pass

Contribution rules:

- One PR = one focused API, map, SDK, privacy, or documentation change.
- Do not commit API keys, tokens, or captured user location data.
- Keep demo users configurable and clearly documented.
- Include simulator/device notes for map behavior changes.
- Preserve map coordinate guards for malformed Twitter timeline results.
- Keep `.github/workflows/check.yml` in sync with the local static project
  checker.

## Security And Responsible Use

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Mapping people from social data can expose location and identity information.
The app should use explicit demo data, avoid storing user locations, and make
API and crash-reporting behavior visible.

## What We Will Not Merge (For Now)

- Checked-in Twitter/Fabric credentials
- Hidden location tracking
- Captured user datasets
- Hardcoded coordinate upload endpoints
- Map annotations from non-numeric remote coordinate payloads
- Public tracking behavior without consent and documentation

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
