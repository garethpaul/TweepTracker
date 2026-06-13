# Profile Image Request Generation

## Status: Completed

## Context

Each reusable map pin now owns and cancels its active profile-image data task.
The completion callback does not clear that ownership after success or failure,
so a completed task can remain retained by the annotation view. Clearing it
without correlating the callback would let a late cancelled request erase the
newer task assigned after reuse.

## Priority

Track a small per-pin request generation so only the current callback can
release task ownership or render an image. This completes the cancellation
lifecycle without changing the reviewed URLSession transport boundary.

## Requirements

- R1. Give each `TweepPinAnnotationView` a monotonically changing image request
  generation.
- R2. Advance the generation whenever active image work is cancelled or a new
  request begins.
- R3. Capture the generation associated with each started request.
- R4. Ignore completions whose generation no longer matches the pin view.
- R5. Clear `imageTask` for the matching completion before handling either a
  decoded image or an error.
- R6. Preserve annotation identity, HTTPS, redirect, status, MIME, size,
  decode, main-queue, reuse, and cancellation safeguards.
- R7. Extend portable contracts, hostile mutations, and maintenance docs for
  the generation and completion-release behavior.

## Implementation Units

### Correlate pin image work

**Files:** `location_tracker/ViewController.swift`

Centralize task cancellation on the reusable pin view, advance a request
generation at cancellation and start boundaries, capture the started
generation, and accept completion work only while that generation remains
current. Release the matching task before conditionally assigning the image.

### Preserve portable contracts and records

**Files:** `scripts/check_ios_project.py`, `README.md`, `SECURITY.md`,
`VISION.md`, `CHANGES.md`,
`docs/plans/2026-06-13-profile-image-request-generation.md`

Require generation ownership, cancellation invalidation, matching completion,
task release ordering, annotation identity, and completed plan evidence.

## Verification Plan

- local and external-working-directory `make check` under hard timeouts
- focused hostile mutations for generation removal, missing cancellation
  invalidation, missing start increment, removed completion match, removed task
  release, release ordering, annotation identity, documentation drift, and
  stale plan status
- Python compilation, plist/XML/JSON/workflow parsing, intended-path,
  generated-artifact, whitespace, and changed-line secret audits

## Scope Boundaries

- Do not change `URL.downloadImage`, request policy, image sizing, map timing,
  retired Twitter dependencies, project membership, or legacy Swift syntax.
- Do not add caching, retries, new dependencies, live network calls, or claim
  simulator execution on Linux.

## Work Completed

- Added a per-pin request generation and centralized cancellation that
  invalidates the generation before cancelling and releasing the task.
- Captured a fresh generation for each profile-image request and ignored stale
  completions before they can clear ownership or render an avatar.
- Cleared the matching task before preserving the existing annotation identity,
  decoded-image, and rendering checks.
- Extended portable source and documentation contracts for generation,
  invalidation, matching, release ordering, and maintenance records.

## Verification

- Local and external-working-directory `make check` passed all portable project
  contract groups under 60-second hard timeouts. Both runs truthfully reported
  iOS test and build skips because `xcodebuild` is unavailable on this Linux
  host.
- Focused hostile mutations for generation removal, cancellation invalidation,
  start capture, completion matching, task release and ordering, annotation
  identity, documentation drift, and plan status were rejected.
- Python compilation, plist/XML/JSON/workflow parsing, intended-path,
  generated-artifact, `git diff --check`, and changed-line secret audits passed
  before shipment.
- No live Twitter request, profile-image download, simulator run, or map UI
  execution was performed.
