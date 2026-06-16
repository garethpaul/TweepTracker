# Runtime Error Log Privacy

## Status: Planned

## Priority

1. Remove raw Twitter request and authentication errors from runtime logs.
2. Preserve every existing failure completion and failed-login navigation guard.
3. Add portable contracts that reject reintroduction of interpolated SDK errors.
4. Keep the broader Swift, Xcode, TwitterKit, and Fabric migration outside this
   focused privacy change.

## Context

The legacy Twitter list, timeline, profile-image, and login callbacks print raw
`NSError` values. SDK errors can include request URLs, query parameters,
account handles, or other service diagnostics that do not belong in device or
CI logs. These messages are not required for the app's fallback behavior:
request failures already complete with empty results, and failed login already
stops navigation.

## Scope

- Remove raw `connectionError`, `clientError`, and login `error` interpolation
  from `location_tracker/FindTweeps.swift`,
  `location_tracker/TweepLocation.swift`,
  `location_tracker/TweepPicture.swift`, and
  `location_tracker/LoginController.swift`.
- Preserve the empty-array, empty-string, and early-return failure behavior.
- Extend `scripts/check_ios_project.py` to reject raw error interpolation in
  those files without banning unrelated user-visible error handling.
- Update `README.md`, `SECURITY.md`, `VISION.md`, and `CHANGES.md` with the
  runtime diagnostic boundary and plan reference.

## Acceptance Criteria

- None of the four Twitter-facing callback files prints or interpolates its
  SDK error object.
- List, timeline, and profile-image failures still call their existing empty
  fallback completions.
- Failed or missing login sessions still return before navigation.
- The static checker requires the completed plan and documentation boundary.
- Each isolated raw-error-log restoration is rejected by `make check`.

## Verification Plan

- Run `make check` from the repository and through the absolute Makefile path
  from an external directory.
- Prove isolated mutations restoring each raw network/auth error log are
  rejected by the static checker.
- Confirm existing fallback completion and login-session contracts still pass.
- Audit the exact diff, generated artifacts, credential paths, and changed
  lines for secret-like values.
- Capture one bounded exact-head hosted check and security-alert snapshot after
  the implementation is pushed.

## Verification

Pending implementation and validation.

## Scope Boundary

This change does not modernize Swift 2 syntax, replace the retired TwitterKit
or Fabric binaries, validate live Twitter behavior, rewrite Git history, or
revoke credentials that may remain in historical commits.
