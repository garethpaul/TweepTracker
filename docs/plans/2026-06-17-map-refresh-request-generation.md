# Map Refresh Request Generation

## Status: Completed

## Priority

1. Prevent callbacks from an older map refresh from mutating the current map.
2. Keep loading and reveal state owned by the latest refresh generation.
3. Reject regressions with portable, mutation-sensitive source contracts.
4. Preserve the historical Swift 2, TwitterKit, Fabric, and Linux validation
   boundaries.

## Context

`setupMap()` can be entered again while list, location, picture, or delayed UI
callbacks from an earlier invocation are still pending. Those callbacks have no
request ownership check, so an older refresh can add stale annotations, reveal
the map, stop the spinner, or redisplay the refresh control after a newer
refresh has started.

## Requirements

- R1. Give `ViewController` a monotonically increasing map refresh generation.
- R2. Capture the active generation at the start of every `setupMap()` call.
- R3. Remove existing non-user annotations when a new refresh begins.
- R4. Require the captured generation before processing list, location, and
  picture completions.
- R5. Require the captured generation before delayed map reveal and refresh
  control work changes UI state.
- R6. Preserve map region, spinner, image-request, annotation-reuse, transport,
  and existing empty-result behavior.
- R7. Extend portable contracts and documentation so isolated ownership,
  callback, cleanup, and plan-status regressions fail `make check`.

## Implementation Units

### U1. Own map refresh callbacks

**Files:** `location_tracker/ViewController.swift`

Introduce a refresh generation owned by the controller, capture it in
`setupMap()`, clear prior non-user annotations, and pass the generation through
the location and picture callback chain. Guard each asynchronous boundary and
both delayed UI blocks before performing side effects.

### U2. Enforce the ownership contract

**Files:** `scripts/check_ios_project.py`

Add a focused map-refresh contract that requires generation capture,
non-user-annotation cleanup, guarded callback ordering, and delayed UI guards.
The contract must reject partial implementations that protect only the outer
list callback or only the final reveal.

### U3. Record the maintenance boundary

**Files:** `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
`docs/plans/2026-06-17-map-refresh-request-generation.md`

Document that only the latest refresh may mutate map content or loading UI and
record completed verification evidence after implementation.

## Verification Plan

- Run repository-root and external-working-directory `make check` under hard
  timeouts.
- Reject isolated mutations removing generation increment/capture, annotation
  cleanup, list/location/picture guards, reveal/refresh guards, documentation,
  or completed plan status.
- Compile the checker, parse project resources, and audit the exact intended
  diff, generated artifacts, conflict markers, and secret-like values.
- Capture one bounded exact-head PR/check and security snapshot after push.

## Scope Boundaries

- Do not modernize Swift syntax or replace the retired TwitterKit, Fabric, or
  Crashlytics binaries in this focused change.
- Do not add retries, cancellation APIs unavailable in the current helper
  signatures, new dependencies, live Twitter requests, or simulator claims.
- Do not merge or close the existing stacked pull requests.

## Work Completed

- Added a controller-owned map refresh generation and captured it before every
  list request.
- Removed prior non-user annotations when a new refresh starts.
- Propagated refresh ownership through list, location, and picture callbacks
  and guarded both delayed loading UI transitions. The refresh control is
  hidden at generation start to avoid overlapping user-triggered requests.
- Extended portable source and documentation contracts for ownership,
  propagation, cleanup, callback counts, ordering, and completed plan evidence.

## Verification

- Repository and external-directory `make check` passed all eight portable
  project contracts; iOS test and build execution were skipped because this
  Linux host does not provide `xcodebuild`.
- Ten isolated map-refresh-generation mutations were rejected across state,
  capture, cleanup, UI gating, propagation, callback, documentation, and
  plan-status boundaries.
- Python syntax, exact diff, generated-artifact, conflict-marker, and
  secret-pattern audits are required again before shipment.
- No live Twitter request, simulator run, or map UI execution was performed.
