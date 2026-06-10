# Profile Image Transport Hardening

## Status: Completed

## Context

The legacy image helper accepted any URL scheme returned by the retired Twitter
API, performed network and image decode work on the main operation queue, and
did not validate response status, MIME type, or size. The tracked plist also
lacked explicit contracts preventing credential additions or broad App
Transport Security exceptions.

## Objectives

- Accept remote profile images only over HTTPS.
- Bound request duration and response size.
- Require a successful HTTP status and image MIME type before decoding.
- Keep network and decode work off the main operation queue while delivering UI
  completion on the main queue.
- Prevent tracked Twitter/Fabric credentials and ATS weakening.
- Fix hosted verification to a stable runner and make commands root-independent.

## Work Completed

- Added HTTPS, 2xx status, image MIME, five-megabyte, timeout, and decode guards
  to `URL.downloadImage`.
- Moved image request/decode work to a background operation queue and dispatches
  every completion back to the main queue.
- Extended plist, source, workflow, action annotation, and Makefile contracts.
- Updated security and maintenance documentation with the supported boundary.

## Verification

- `make check`
- `make -f /path/to/TweepTracker/Makefile check` outside the repository
- Scheme, status, MIME, size, queue, plist credential, runner, action annotation,
  and Makefile path mutations rejected by the static checker
- `git diff --check`

Full Swift compilation remains dependent on a historical toolchain and retired
vendored TwitterKit/Fabric/Crashlytics binaries.
