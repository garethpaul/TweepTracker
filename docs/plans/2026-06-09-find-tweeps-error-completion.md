# FindTweeps Error Completion Guard

## Status: Completed

## Context

`setupMap()` waits for `FindTweeps` to call its completion before it reveals the
map and schedules the refresh control. If the Twitter list-member request fails
to build or returns a transport error, `FindTweeps` logged the error but did not
call the completion, leaving the map setup path unfinished.

## Objectives

- Preserve the Twitter list-to-map flow.
- Keep successful list parsing and supplemental handles unchanged.
- Complete request setup and transport error paths with an empty handle list.
- Extend static checks so error completions are not removed.

## Work Completed

- Added `completion(result: [])` for Twitter request transport failures.
- Added `completion(result: [])` when the Twitter request cannot be created.
- Extended `scripts/check_ios_project.py` to require both error completions.
- Updated README, VISION, and CHANGES.

## Verification

- Negative check before implementation:
  `python3 scripts/check_ios_project.py` failed with
  `list-member request error paths must complete with an empty result`.
- `python3 scripts/check_ios_project.py`
- `make check`
- `make verify`
- `git diff --check`

## Xcode Notes

`xcodebuild` was not available in this environment, so simulator build and test
steps were skipped. The repository `make check` wrapper still runs them when
`xcodebuild` is available locally.
