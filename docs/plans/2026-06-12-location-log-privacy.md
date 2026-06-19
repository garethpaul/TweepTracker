# Location Log Privacy

## Status: Completed

## Context

The legacy map controller retains an unused placemark-display helper that logs
locality, postal code, administrative area, and country. AppDelegate also
contains a dormant Core Location callback with commented coordinate logging.
Neither path contributes to the visible map workflow, and both normalize
copying location data into diagnostic output.

## Objectives

- Remove unused placemark and coordinate logging surfaces.
- Preserve map annotation, Twitter lookup, and visible UI behavior.
- Keep generic request-error diagnostics unchanged.
- Reject restoration of the removed location-log paths with portable contracts.

## Scope

- Remove the unused placemark-display method from `ViewController`.
- Remove the unused location callback and now-unneeded Core Location import
  from `AppDelegate`.
- Update privacy, maintenance, vision, and change documentation.
- Do not modernize the retired TwitterKit/Fabric stack or claim live-service
  validation.

## Verification

- Implementation-specific source, project, workflow, and privacy contracts
  passed before plan completion.
- `python3 scripts/check_ios_project.py` and `make check` passed locally; Xcode
  test and build steps reported explicit skips because Xcode is unavailable on
  this Linux host.
- An absolute-path `make -f .../TweepTracker/Makefile check` invocation passed
  from `/tmp`, confirming caller-directory independence.
- Four hostile mutations restoring the placemark helper, Core Location import,
  coordinate access, or incomplete plan status were rejected.
- `python3 -m py_compile scripts/check_ios_project.py` and `git diff --check`
  passed.
