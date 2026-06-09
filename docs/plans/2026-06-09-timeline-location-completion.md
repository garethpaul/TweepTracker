# Timeline Location Completion

## Status: Completed

## Context

`TweepLocation` parsed a user's timeline for the first usable geo coordinate,
but malformed JSON, no-coordinate timelines, request setup failures, and
transport failures could return without invoking the completion callback. The
map caller already guards empty coordinate arrays, so the lookup should always
complete with either one normalized coordinate pair or an empty result.

## Objectives

- Complete successful timeline responses even when no coordinates are found.
- Complete request setup and transport failures with an empty coordinate result.
- Preserve normalized latitude/longitude ordering before map annotations use it.
- Extend static checks to keep completion behavior in place.

## Work Completed

- Added an empty `coordinateResult` fallback in `TweepLocation`.
- Stored the first valid normalized coordinate pair before finishing parsing.
- Completed with `coordinateResult` for parsed responses and `[]` for request
  errors.
- Extended `scripts/check_ios_project.py` to require the completion guard.
- Updated README, VISION, and CHANGES.

## Verification

- `python3 scripts/check_ios_project.py`
- `make check`
- `git diff --check`

`xcodebuild` is not available in this environment, so iOS build and test
verification were skipped after static checks passed.

## Follow-Up Candidates

- Make fallback demo handles configurable instead of hardcoded.
- Add simulator-backed map annotation tests when the legacy iOS toolchain is
  available.
