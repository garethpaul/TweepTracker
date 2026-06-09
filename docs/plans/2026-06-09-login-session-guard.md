# Login Session Guard

## Status: Completed

## Context

`LoginController` performed the map-view segue unconditionally from the
TwitterKit login completion callback. If TwitterKit reported an error or did
not return a session, the app could navigate into the map flow without an
authenticated Twitter session.

## Objectives

- Keep failed Twitter login attempts on the login screen.
- Preserve the existing segue for successful login sessions.
- Extend static checks so the login guard runs before navigation.

## Work Completed

- Added a `session == nil || error != nil` guard before the map-view segue.
- Logged the login error and returned without navigating on failure.
- Extended `scripts/check_ios_project.py` to require the guard before
  `performSegueWithIdentifier`.
- Updated README, VISION, and CHANGES with the new login contract.

## Verification

- `python3 scripts/check_ios_project.py`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Replace hardcoded supplemental demo handles with configurable fixture data.
- Add simulator-backed login-flow checks when the legacy SDK setup is
  available.
