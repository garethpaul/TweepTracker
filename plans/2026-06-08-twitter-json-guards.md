# Twitter JSON Guard Gate

## Problem

The Tweep lookup helpers parsed remote Twitter API responses with force unwraps
for timeline entries, coordinate arrays, and profile image URLs. Empty
timelines, missing geo data, or profile responses without an image URL could
crash the sample before the map had a chance to continue.

## TDD Evidence

1. Extended `scripts/check_ios_project.py` with static checks for Twitter JSON
   parsing guardrails.
2. Ran `make lint` before changing Swift and confirmed the new guard failed on
   the forced first-tweet unwrap.
3. Replaced the force unwraps with optional dictionary/array parsing and reran
   the full verification gate.

## Verification

- `make lint`
- `make test`
- `make build`
- `make verify`
- `make check`
- `git diff --check`
