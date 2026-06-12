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
- Avoid blocking map setup while waiting to reveal loaded annotations
- Complete Twitter list lookups even when request setup or transport fails
- Complete Twitter timeline coordinate lookups even when responses lack usable
  coordinates
- Complete Twitter profile-image lookups even when no usable image URL is
  returned
- Avoid hardcoded external upload paths for user coordinates
- Keep GitHub Actions aligned with the local Python `make check` baseline

Next priorities:

- Add setup notes for legacy SDK requirements and current API limitations
- Add privacy notes for geolocation and profile images
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
