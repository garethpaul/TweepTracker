# Map Pop Callback Invalidation

status: completed

## Problem

Map refresh generations reject callbacks from superseded refreshes, but popping
the map controller leaves the active generation valid. Late list, location,
profile-picture, reveal, and refresh callbacks can therefore mutate the removed
controller, while visible avatar tasks continue obsolete work.

## Design

On a completed navigation pop, increment the refresh generation before removing
owned UI, cancel visible pin image tasks, and detach the map delegate. Existing
callback guards then reject all work owned by the removed scene without changing
normal push or refresh behavior.

## Verification Completed

- RED: the static checker rejected the missing pop-time ownership contract.
- Added source contracts for generation invalidation, visible pin task
  cancellation, delegate detachment, and navigation logo removal.
- Three hostile teardown mutations are rejected independently: generation
  invalidation removal, pin cancellation removal, and delegate detachment
  removal.
- Codex review found refresh-start invalidation was no longer uniquely scoped;
  an additional hostile mutation now removes the `setupMap()` increment and the
  checker validates ordering within that function only.
- `make check` passes eight static checks, ten review-contract tests, Make
  authority tests, and the sanitized wrapper tests.
- `git diff --check` passes.
- Legacy Xcode execution remains opt-in and was not run on this host.
- No credentials, live Twitter request, profile image, or location data was used.
