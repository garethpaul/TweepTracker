# Coordinate Number Validation

## Status: Completed

## Context

Timeline geocode parsing verified that Twitter coordinate arrays had at least
two entries, but then called `doubleValue` on untyped `AnyObject` values. That
could silently coerce malformed coordinate payloads instead of treating them as
missing data.

## Objectives

- Require latitude and longitude JSON entries to be numeric before returning
  coordinates.
- Preserve the existing normalized `[latitude, longitude]` result order.
- Keep malformed timeline payloads completing with the empty fallback result.
- Extend static checks so numeric coordinate validation stays in place.

## Work Completed

- Guarded timeline latitude and longitude values with `NSNumber` casts.
- Kept successful coordinates returned as `[lat.doubleValue, lng.doubleValue]`.
- Extended `scripts/check_ios_project.py` to require the numeric guards and
  completed plan.
- Updated README, VISION, and CHANGES.

## Verification

- Negative: source review showed untyped coordinate entries were used through
  `doubleValue`.
- `python3 scripts/check_ios_project.py`
- `make check`
- `make verify`
- `git diff --check`

`xcodebuild` is not installed in this environment, so the Makefile test and
build steps reported the expected static-only fallback.

## Follow-Up Candidates

- Add simulator-backed map annotation coverage when Xcode is available.
- Add a small pure parser wrapper around Twitter timeline coordinate payloads
  if this legacy code is modernized.
