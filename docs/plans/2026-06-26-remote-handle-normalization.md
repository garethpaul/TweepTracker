# Remote Twitter Handle Normalization

status: completed

## Context

Checked-in supplemental handles were trimmed, syntax-bounded, and deduplicated,
but remote list-member `screen_name` values were appended directly to the map
fan-out. A malformed, overlong, or duplicate response value could trigger
unnecessary per-user timeline and profile-image requests.

## Requirements

- Share one Swift 2-compatible normalizer across remote and configured handles.
- Accept only trimmed 1–15 character ASCII letters, digits, and underscores.
- Deduplicate case-insensitively while preserving first-seen display spelling
  and order.
- Normalize the final combined list before any per-handle request fan-out.
- Preserve Twitter response validation, empty failure completions, configured
  defaults, and map refresh generation ownership.

## Verification Completed

- RED: the focused review contract failed because production source had no
  shared handle normalizer or final fan-out normalization.
- GREEN: `python3 scripts/test_review_contracts.py` passed 13 contracts and
  `python3 scripts/check_ios_project.py` passed eight static checks.
- Repository-root and external-directory `make check` passed with 13 hostile
  mutations rejected.
- The checked-in XCTest source covers malformed remote values and
  case-insensitive duplicates across remote/configured-style inputs.
- No live Twitter request, credential, device location, or profile image was
  used during verification.

## Scope Boundaries

- Keep the configured supplemental defaults unchanged.
- Do not claim legacy Xcode execution without a compatible Swift 2/iOS
  toolchain.
- Do not modernize TwitterKit, Fabric, Crashlytics, or map behavior in this PR.
