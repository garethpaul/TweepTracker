# TweepTracker Baseline

## Status: Completed

## Context

`TweepTracker` is a legacy Swift iOS sample that maps selected Twitter users
with bundled Fabric, Crashlytics, and TwitterKit frameworks. The repository is
mostly useful as an archive, so the maintenance baseline should preserve the
project while keeping Xcode metadata, app resources, and remote Twitter JSON
parsing behavior statically verifiable.

## Objectives

- Preserve the checked-in Xcode project, app/test plist files, storyboards, and
  asset catalogs.
- Keep Twitter/Fabric credentials out of git and document that the SDKs are
  legacy.
- Avoid force-unwrapping remote Twitter list, timeline, coordinate, and profile
  image fields.
- Run plist, storyboard, asset, Xcode project, docs-plan, and Twitter JSON
  parsing checks through `make check`.
- Keep Xcode build/test execution optional for hosts with `xcodebuild`.

## Work Completed

- Added canonical `docs/plans` coverage for the current TweepTracker baseline.
- Extended `scripts/check_ios_project.py` to require completed docs plans with
  `make check` verification.
- Guarded list-member JSON parsing in `FindTweeps.swift`.
- Updated README and CHANGES to make the canonical baseline discoverable.

## Verification

- `python3 scripts/check_ios_project.py`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add setup notes for the specific Xcode, Swift, and TwitterKit/Fabric era.
- Replace bundled discontinued SDK frameworks in a dedicated modernization
  pass.
- Move hardcoded demo handles into explicit local demo configuration.
