---
title: "refactor: Move profile image transport to NSURLSession"
type: refactor
date: 2026-06-13
---

# Move Profile Image Transport to NSURLSession

## Status: Completed

## Context

The profile-image path already validates HTTPS requests and redirects, status,
MIME type, response size, decode results, and main-queue callbacks. Its network
primitive remains the deprecated `NSURLConnection.sendAsynchronousRequest` API.

## Requirements

- R1. Start profile-image requests with an `NSURLSession` data task.
- R2. Explicitly resume the task so requests execute.
- R3. Remove the deprecated asynchronous `NSURLConnection` call.
- R4. Preserve the 15-second request timeout, cache policy, HTTPS request and
  final-response checks, 2xx/image/5 MiB limits, and optional decode behavior.
- R5. Preserve off-main completion work and main-queue UI callbacks.
- R6. Protect the migration with portable static and hostile mutation checks.

## Scope Boundaries

This change replaces only the transport primitive. It does not modernize the
project's Swift language version, retired Twitter dependencies, image cache,
callback signature, or annotation-view behavior.

## Implementation Units

### U1. Replace the Deprecated Transport Primitive

- **Goal:** Use the session-based request API without weakening existing
  response validation.
- **Files:** `location_tracker/URL.swift`
- **Approach:** Create a shared-session data task from the existing configured
  request, retain the current completion body, and resume the task after the
  closure is installed.
- **Test scenarios:** Static source contains the session, data-task, and resume
  path; the deprecated connection call is absent; every existing guard remains.
- **Verification:** Portable contracts prove the complete source shape.

### U2. Extend Mutation-Resistant Contracts

- **Goal:** Prevent a silent no-op task or regression to the old API.
- **Files:** `scripts/check_ios_project.py`
- **Approach:** Require session creation, data-task creation, and task resume;
  forbid `NSURLConnection`; retain all existing transport contracts except the
  obsolete operation-queue fragment.
- **Test scenarios:** Mutations removing session use, data-task creation, task
  resume, old-API prohibition, or main-queue delivery are rejected.
- **Verification:** The checker reports each weakened contract independently.

### U3. Record the Transport Migration

- **Goal:** Document the completed compatibility improvement and actual test
  boundary.
- **Files:** `README.md`, `VISION.md`, `CHANGES.md`,
  `docs/plans/2026-06-13-profile-image-urlsession.md`
- **Approach:** Record the session migration while retaining the broader legacy
  Swift and retired dependency limitations.
- **Test expectation:** Documentation is enforced by the completed-plan
  checker; no separate runtime behavior is introduced.
- **Verification:** The plan distinguishes local portable checks from missing
  Xcode/runtime execution.

## Risks

- Forgetting `resume()` would compile but never invoke the completion handler.
- Moving callback delivery off the main queue would make annotation UI updates
  unsafe.
- Removing response validation during the refactor would reopen the hardened
  transport boundary.

## Assumptions

- The existing Swift toolchain accepts `NSURLSession.sharedSession()` and
  `dataTaskWithRequest`, which were available for the project's deployment era.

## Work Completed

- Replaced `NSURLConnection.sendAsynchronousRequest` with a shared-session data
  task built from the existing bounded request.
- Explicitly resumed the task after installing the completion handler.
- Preserved request and final-response HTTPS checks, timeout, cache policy, 2xx
  status, image MIME, 5 MiB, decode, and main-queue callback safeguards.
- Strengthened the checker to require all three callback exits to dispatch on
  the main queue.
- Added static contracts for session creation, data-task creation, resume, and
  legacy API prohibition.
- Updated maintenance and product documentation.

## Verification

- `make check` passed all eight portable project contract groups
- Local iOS tests and build were truthfully skipped because `xcodebuild` is not
  available on this Linux host
- Five hostile mutations covering session, data task, resume, legacy API, and
  main-queue completion contracts were rejected
- `python -m py_compile scripts/check_ios_project.py`
- `git diff --check`

The successor PR remains subject to its hosted push/pull-request and CodeQL
checks; no live profile image request or simulator execution is claimed here.
