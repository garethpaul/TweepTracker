# Map Coordinate Order Guard

## Status: Completed

## Context

`TweepLocation` normalizes Twitter coordinate JSON into `[latitude, longitude]`
before returning it to `ViewController.locateTweep`. The map annotation path
then indexes the array without checking its size and passes the values to
`CLLocationCoordinate2D` in the opposite order.

## Objectives

- Preserve the Twitter timeline-to-map annotation flow.
- Avoid indexing malformed coordinate arrays.
- Pass normalized latitude and longitude to `CLLocationCoordinate2D` in the
  same order returned by `TweepLocation`.
- Extend the static project checker to preserve the coordinate order guard.

## Work Completed

- Added a result-size guard before `locateTweep` indexes timeline coordinates.
- Updated `CLLocationCoordinate2D` construction to use normalized
  `[latitude, longitude]` order.
- Extended `scripts/check_ios_project.py` to preserve the guard and order.
- Updated README, VISION, and CHANGES.

## Verification

- `python3 scripts/check_ios_project.py`
- `make check`
- `make verify`
- `git diff --check`
