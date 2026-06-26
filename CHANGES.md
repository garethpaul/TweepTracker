# Changes

## 2026-06-26T03:14:02Z — P1 correctness — cycle: HTTPS avatar field

### Summary
Restored profile-image loading by aligning Twitter user-object parsing with the
app's existing HTTPS-only image transport.

### Work completed
- Switched avatar parsing from deprecated `profile_image_url` to the documented
  `profile_image_url_https` field.
- Added source contracts and a hostile mutation that reject regression to the
  non-HTTPS field.
- Documented the transport invariant and focused design decision.

### Validation
- RED: the static checker rejected the parser while it selected the old field.
- GREEN: portable verification passes after selecting the HTTPS field.
- Exact-head Codex review was attempted but could not authenticate to the
  OpenAI API (`401 Unauthorized`); manual diff review found no issues.
- Hosted portable checks and CodeQL Actions/Python analysis passed.
- Legacy Xcode execution remains opt-in and was not run on this host.

## 2026-06-25T21:36:49Z — P1 correctness/privacy — cycle: map pop callback invalidation

### Summary
Closed the navigation-pop lifecycle gap so asynchronous map work cannot mutate
a controller after it has been removed from the navigation stack.

### Work completed
- Invalidated the active map refresh generation after a completed pop.
- Cancelled visible pin profile-image tasks and detached the map delegate.
- Added exact source contracts and three hostile teardown mutations.
- Updated maintenance and privacy guidance.

### Threads
- Started: navigation-pop ownership for map refresh callbacks and pin tasks.
- Continued: refresh-vs-refresh generation guards and deterministic logo cleanup.
- Stopped: none.

### Files changed
- `location_tracker/ViewController.swift`, checker and mutation tests,
  documentation, and `docs/plans/2026-06-25-map-pop-callback-invalidation.md`.

### Validation
- RED: the checker rejected the missing pop-time map invalidation contract.
- GREEN: `make check` passes eight static checks and ten review-contract tests.
- Legacy iOS build/test remains opt-in and was not run on this host.
- Codex review found the second generation increment could mask removal of the
  refresh-start increment; contracts and mutation coverage now scope it to
  `setupMap()`.

### Bugs / findings
- P1: list, location, picture, and delayed UI callbacks retained a valid
  generation after navigation pop and could mutate removed map UI.
- P2: visible avatar downloads continued obsolete work after the map was popped.
- P2 review: the initial static ordering check matched the new pop increment
  first and could miss removal of `setupMap()` invalidation.

### Blockers
- The preserved Swift 2/iOS 8 app, vendored SDKs, credentials, and live Twitter
  APIs require a compatible historical device/toolchain and controlled account.

### Next action
- Require exact-head Codex review and hosted portable/CodeQL checks before merge.

## 2026-06-25

- Added deterministic navigation-overlay teardown. Popped map controllers remove their navigation logo overlay.
- Added portable source contracts and a hostile teardown mutation.

- Added a sanitized fixed-target Make wrapper for hosted and contributor
  verification, with physical-checkout resolution and regression coverage for
  pre-parse GNU Make option, startup-file, and extra-`-f` authority.
- Hardened portable Make verification against interpreter syntax expansion,
  shell and Makefile identity replacement, skipped-mode flags, startup-file
  configuration, and unsafe legacy-Xcode opt-in values.

## 2026-06-19

- Validated Twitter API responses for HTTPS, 2xx status, JSON content type,
  declared size, and received size before parsing.
- Rejected Boolean, non-finite, and out-of-range tweet coordinates and reduced
  displayed coordinate precision to two decimal places.
- Replaced completion-handler image buffering with a streaming data delegate
  that cancels responses exceeding the five-megabyte limit.
- Assigned suspended avatar tasks to their pin before resuming them and
  cancelled visible pin tasks before refresh-time annotation removal.
- Confirmed the app declares no device-location permission and documented that
  both historically exposed Fabric credentials require provider-side
  revocation or retirement.
- Made archival Xcode execution an explicit `RUN_LEGACY_XCODE=1` opt-in so the
  default `make check` remains portable on modern macOS hosts.

## 2026-06-17

- Added map refresh generation ownership so stale list, location, picture, and
  delayed reveal callbacks cannot mutate the current annotations or loading UI;
  new refreshes also clear prior non-user annotations before requesting data.

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
