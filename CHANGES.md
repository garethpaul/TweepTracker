# Changes

## 2026-06-16

- Removed raw Twitter request and authentication error objects from runtime
  logs while preserving existing fallback completions and failed-login guards;
  added fail-closed runtime error log privacy contracts.

## 2026-06-14

- Removed a legacy Fabric upload shell phase that embedded credentials in the
  Xcode project, and added static guards against Fabric commands and PBX shell
  build phases returning.
- Documented the legacy SDK compatibility boundary for the iOS 8.0/8.1
  project settings, Swift 2-era source, vendored Twitter/Fabric binaries,
  local-only credentials, and unverified live API behavior.

## 2026-06-13

- Added per-pin request generations so matching profile-image completions
  release task ownership while stale callbacks cannot clear newer work.
- Added per-pin URLSession task ownership and cancellation so reused annotation
  views stop obsolete profile-image network and decode work.
- Replaced deprecated asynchronous `NSURLConnection` profile-image loading with
  an explicitly resumed `NSURLSession` data task while retaining all transport
  and callback safeguards.

## 2026-06-12

- Removed an unused placemark helper that logged locality, postal code,
  administrative area, and country.
- Removed a dormant AppDelegate location callback and commented coordinate
  logging examples.
- Added static privacy contracts preventing both location-log surfaces from
  returning.

## 2026-06-10

- Guarded asynchronous avatar assignment against map annotation reuse and
  removed the Tweep annotation force-cast.
- Hardened remote profile-image loading with HTTPS-only URLs, status and MIME
  validation, a five-megabyte limit, a timeout, and background network/decode
  work with main-queue completion.
- Added static guards against tracked Twitter/Fabric plist credentials and App
  Transport Security weakening.
- Fixed the CI runner to Ubuntu 24.04, annotated immutable action revisions,
  scoped concurrency, and made Make targets independent of the caller's path.
- Added a least-privilege GitHub Actions workflow that runs `make check` with
  commit-pinned Node 24 actions, credential-free checkout, all-branch push
  coverage, and a bounded runtime.
- Extended the static project checker and docs to require the hosted CI
  verification path.

## 2026-06-09

- Required Twitter timeline latitude and longitude values to be numeric before
  returning map annotation coordinates.
- Completed profile-image lookup failures and missing image URLs with an empty
  result so map annotation flow can continue.
- Extended static project checks to require profile-image lookup completion
  guards.
- Completed Twitter timeline coordinate lookup failure and no-coordinate paths
  with an empty result.
- Extended static project checks to require timeline coordinate completion
  guards.
- Completed Twitter list-member request error paths with an empty result so map
  setup can continue after request failures.
- Replaced the blocking map reveal sleep with asynchronous dispatch timing.
- Extended static project checks to prevent blocking map setup from returning.
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
