# Nonblocking Map Reveal

## Status: Completed

## Context

`setupMap()` waited for profile-image annotations with `sleep(5)` inside the
Twitter list completion path before stopping the spinner and showing the map.
That blocks the callback path and can freeze UI work when the callback is
delivered on the main queue.

## Objectives

- Preserve the existing delayed map reveal behavior.
- Avoid blocking the async completion path with `sleep`.
- Keep the refresh button delay after the map becomes visible.
- Extend static checks so blocking map setup does not return.

## Work Completed

- Replaced `sleep(5)` with a `dispatch_after` map reveal delay on the main
  queue.
- Kept spinner, map visibility, and refresh button updates on the existing UI
  path.
- Nested the refresh-button delay after the map reveal delay.
- Extended `scripts/check_ios_project.py` to require the asynchronous map
  reveal and reject the blocking sleep.
- Updated README, VISION, and CHANGES.

## Verification

- `python3 scripts/check_ios_project.py`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`

## Verification Notes

- XcodeBuildMCP simulator verification was unavailable in this session.
- `xcodebuild` was unavailable on this host, so `make test` and `make build`
  used their documented skip paths.

## Follow-Up Candidates

- Add simulator-backed map timing checks when the legacy SDK setup is
  available.
- Replace hardcoded supplemental demo handles with configurable fixture data.
