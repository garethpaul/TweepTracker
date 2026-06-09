# Changes

## 2026-06-09

- Guarded Twitter login completion so failed or missing sessions do not segue
  into the map view.
- Extended static project checks to require the login failure guard before
  navigation.
- Removed the unused hardcoded coordinate upload helper from `URL.swift`.
- Extended static project checks to prevent silent external coordinate upload
  paths from returning.
- Guarded map annotation coordinate results before indexing and preserved the
  normalized latitude/longitude order from Twitter timeline parsing.

## 2026-06-08

- Guarded profile image URL creation and image decoding before assigning map
  annotation images.
- Guarded Twitter list-member JSON parsing so missing or malformed `users`
  payloads do not crash the sample.
- Added canonical `docs/plans` coverage to the static project check.
- Guarded Twitter timeline and profile-image JSON parsing so missing remote
  fields do not crash the sample.
- Extended static project checks to catch forced Twitter JSON unwraps.
- Added `make check` as the shared repository verification alias.
- Restored the app and unit-test `Info.plist` files referenced by the Xcode project.
- Added a `make verify` quality gate for plist, storyboard, asset, and project contracts.
- Documented the static verification flow for non-macOS hosts.
