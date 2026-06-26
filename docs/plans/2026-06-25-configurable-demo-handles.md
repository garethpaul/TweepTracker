# Configurable Demo Handles Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Replace production-source supplemental Twitter handles with validated, checked-in app configuration while preserving the sample's current demo users.

**Architecture:** Read a `SupplementalTwitterHandles` Info.plist array through a pure Swift 2-compatible normalizer, then append the normalized values to the guarded list-members result. Lock the boundary with unit tests, static checks, hostile mutations, and documentation.

**Tech Stack:** Swift 2, Foundation, Info.plist, XCTest, Python 3 static contracts, GNU Make.

---

Status: Completed

### Task 1: Prove the missing configuration boundary

**Files:**
- Modify: `scripts/test_review_contracts.py`

1. Add a contract requiring plist-backed supplemental handles and rejecting
   direct production-source handle appends.
2. Run the focused contract and confirm it fails against the current source.

### Task 2: Implement validated configuration

**Files:**
- Modify: `location_tracker/FindTweeps.swift`
- Modify: `location_tracker/Info.plist`
- Modify: `location_trackerTests/location_trackerTests.swift`

1. Add unit cases for missing, malformed, duplicate, and valid configured values.
2. Implement the minimal Swift 2-compatible normalizer.
3. Read the plist value and append only normalized configured handles.
4. Preserve the five existing demo handles in the checked-in plist.

### Task 3: Lock maintenance evidence

**Files:**
- Modify: `scripts/check_ios_project.py`
- Modify: `scripts/test_review_contracts.py`
- Modify: `README.md`
- Modify: `VISION.md`
- Modify: `AGENTS.md`
- Modify: `CHANGES.md`
- Modify: `docs/plans/2026-06-25-configurable-demo-handles.md`

1. Add source, configuration, test, documentation, and mutation contracts.
2. Run `make lint`, `make test`, `make build`, and `make check`.
3. Record unavailable legacy Xcode/device/live-Twitter validation honestly.

## Verification Evidence

- RED: the focused review contract failed because
  `SupplementalTwitterHandles` was absent from app configuration.
- GREEN: all Make aliases and external-root `make check` passed with 12 review
  contracts and 12 hostile mutations; Python parsed the app plist and verified
  the reviewed default handles.
- Hosted Check runs `28214940238` and `28214941959` and CodeQL run
  `28214940917` passed on the implementation head.
- `codex-review --mode branch` selected `origin/master` but failed with OpenAI
  API HTTP 401 and was skipped per the maintenance instruction.
- No live Twitter request, device location, credential, or legacy Xcode build
  is claimed by the portable verification.
