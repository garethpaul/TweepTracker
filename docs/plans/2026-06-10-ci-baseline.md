# CI Baseline

status: completed

## Context

The repository had a local `make check` baseline for the legacy iOS project and
Twitter JSON guard checks, but no hosted workflow ran it for pushes and pull
requests.

## Changes

- Added a GitHub Actions workflow that installs Python 3.12 and runs
  `make check`.
- Extended the static project checker and docs so the hosted CI baseline stays
  visible.

## Verification

- `make check`
