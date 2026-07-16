# Guard Neutering Contracts

status: completed

## Problem

The Twitter response metadata/size guards and the coordinate privacy guards were
asserted as bare condition fragments (`"httpResponse!.statusCode >= 300"`,
`"CFGetTypeID(number) == CFBooleanGetTypeID()"`, `"isfinite(coordinate) == 0"`,
...) with `in`-containment checks in both `scripts/check_ios_project.py` and
`scripts/test_review_contracts.py`.

A fragment-containment assertion proves the text *exists*; it never proves the
condition *does* anything. Keeping each literal byte-identical, uncommented and
still evaluated, while removing the `if`/`return nil` that it gates, defeats the
guard with the gate green:

```swift
let rejectsResponse = response?.URL?.scheme?.lowercaseString != "https" ||
    httpResponse == nil || httpResponse!.statusCode < 200 ||
    httpResponse!.statusCode >= 300 ||
    (mimeType != "application/json" && mimeType != "text/json")
_ = rejectsResponse
```

Nothing in the repository compiles or executes the Swift: CI runs on
`ubuntu-24.04` with Python only, and `make test`/`make build` print
"iOS tests skipped"/"iOS build skipped" unless `RUN_LEGACY_XCODE=1` finds an
`xcodebuild`. Source-text assertions are therefore the *only* thing standing
behind these guards, so a neutering edit had no other backstop.

`test_hostile_mutations_are_rejected` already existed, but all fourteen of its
mutations *changed or deleted* an asserted literal — the case fragment
assertions do catch. None kept the literal intact, so the blind spot was not
covered.

## Design

Pin the whole guard construct instead of bare fragments, following the
`pop_logo_teardown` contract already used in this repository, which pins an
entire function body. Each condition must be shown gating its `return nil`.

Add three neutering ("decoy") mutations to `test_hostile_mutations_are_rejected`
so the strengthened contracts stay strengthened.

The shipped Swift is unchanged: the guards were already correct and live. This
closes a verification gap, not a live defect.

## Verification Completed

- Mutation study on the full gate (`./scripts/run-make.sh check`), each probe
  with a proven applied-count of 1, before the fix: 3 neutering decoys NOT
  CAUGHT (exit 0), 3 comment-out probes NOT CAUGHT (exit 0), 3 delete-the-guard
  controls CAUGHT (exit 2). Deletion caught + neutering not caught = the gate was
  live but blind.
- After the fix: 8/8 probes CAUGHT, each with its own specific diagnostic naming
  the guard, e.g. "Twitter response metadata guard must reject non-HTTPS,
  non-2xx, and non-JSON responses by returning nil; each condition must gate that
  return, not merely appear".
- Swift block-comment (`/* */`) wrapping of the coordinate guard is also rejected.
- Clean tree passes `make check` (via `./scripts/run-make.sh check`, as CI runs
  it): eight static checks, thirteen review-contract tests, Make authority tests,
  sanitized wrapper tests.
- Legacy Xcode execution remains opt-in and was NOT run: no Swift toolchain and
  no `xcodebuild` exist on this host, so the Swift was never compiled or
  executed. The guards' runtime behavior was not observed, only their source
  structure.
- No credentials, live Twitter request, profile image, or location data was used.
