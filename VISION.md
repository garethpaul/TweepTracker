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

Next priorities:

- Add setup notes for legacy SDK requirements and current API limitations
- Replace hardcoded supplemental handles with configurable demo data
- Add privacy notes for geolocation and profile images
- Modernize Swift only in a dedicated pass

Contribution rules:

- One PR = one focused API, map, SDK, privacy, or documentation change.
- Do not commit API keys, tokens, or captured user location data.
- Keep demo users configurable and clearly documented.
- Include simulator/device notes for map behavior changes.

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
- Public tracking behavior without consent and documentation

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
