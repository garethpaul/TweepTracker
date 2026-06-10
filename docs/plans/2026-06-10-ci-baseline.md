# TweepTracker Static Contract Gate

## Status: Completed

## Context

The repository has deterministic static checks for the legacy Xcode project,
Twitter response parsing, location result ordering, numeric coordinate guards,
profile image completion, and maintenance plans. Full compilation depends on a
historical Swift toolchain and retired vendored TwitterKit/Fabric binaries, so
the portable contracts are the appropriate hosted verification surface.

## Objectives

- Run all portable contracts on pushes and pull requests.
- Keep the workflow least-privilege, immutable, and bounded.
- Preserve a manual maintenance trigger.
- Avoid presenting the retired SDK bundle as supported or validated.

## Work Completed

- Added `.github/workflows/check.yml` for pushes to `master`, pull requests,
  and manual runs.
- Granted only read access to repository contents and set a five-minute timeout.
- Pinned checkout and Python setup actions to immutable Node 24 commits.
- Ran the existing `make check` entry point with Python 3.12.
- Extended `scripts/check_ios_project.py` to enforce workflow triggers,
  permissions, timeout, action pins, runtime, and command.
- Updated README, SECURITY, VISION, and CHANGES with the hosted baseline.

## Verification

- `python3 -m py_compile scripts/check_ios_project.py`
- `python3 scripts/check_ios_project.py`
- `make check`
- `git diff --check`

The Linux job validates static source and repository contracts only. It does
not compile Swift, run XCTest, execute TwitterKit/Fabric/Crashlytics binaries,
contact Twitter services, or process real user locations.
