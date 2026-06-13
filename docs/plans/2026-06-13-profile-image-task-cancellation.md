# Profile Image Task Cancellation

## Status: In Progress

## Context

Reused map pins clear stale images and reject callbacks for a different
annotation, but their obsolete profile-image URLSession tasks continue using
network and decode resources until completion.

## Requirements

- R1. Return the created `NSURLSessionDataTask` from the image loader while
  preserving synchronous validation failures and main-queue completions.
- R2. Store the current image task on a dedicated pin annotation view subtype.
- R3. Cancel and clear the task in `prepareForReuse`.
- R4. Cancel any prior task before assigning a new annotation or starting a new
  image request.
- R5. Preserve HTTPS, redirect, status, MIME, size, decode, main-queue, and
  annotation-identity safeguards.
- R6. Portable contracts and hostile mutations must preserve cancellation and
  task ownership.

## Scope Boundaries

- Do not modernize the legacy Swift syntax or retired Twitter dependencies.
- Do not add caching, retries, new dependencies, or project-file membership.
- Do not claim live network, simulator, or UI execution on Linux.

## Implementation Units

### U1. Return the URLSession task

- **Files:** `location_tracker/URL.swift`
- Return an optional task, return `nil` for rejected non-HTTPS input, and keep
  the existing completion behavior.

### U2. Own and cancel per-pin work

- **Files:** `location_tracker/ViewController.swift`
- Add a local annotation-view subtype, cancel in `prepareForReuse`, cancel on
  reassignment, store the new task, and retain the callback identity guard.

### U3. Preserve contracts and documentation

- **Files:** `scripts/check_ios_project.py`, `README.md`, `SECURITY.md`,
  `VISION.md`, `CHANGES.md`
- Enforce task return, subtype use, both cancellation boundaries, and the
  existing stale-result defense.

## Verification

- Local and external-directory `make check` with truthful Xcode skips
- Hostile mutations removing return, ownership, cancellation, or identity guard
- Python compilation, structured-file parsing, `git diff --check`, and focused
  secret/artifact review
