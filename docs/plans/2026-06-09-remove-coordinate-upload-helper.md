# Remove Coordinate Upload Helper

## Status: Completed

## Context

`URL.swift` still contained an unused helper that posted latitude and longitude
values to a hardcoded App Engine endpoint. The live path was only referenced by
a commented-out call, but keeping a coordinate upload helper in a location
mapping sample conflicts with the repository's privacy guardrails and makes
future accidental use easier.

## Objectives

- Preserve the Twitter list-to-map annotation flow.
- Remove unused hardcoded coordinate upload code.
- Keep profile-image downloads intact.
- Extend static checks so the external coordinate endpoint does not return.

## Work Completed

- Removed the unused `geo` helper from `URL.swift`.
- Removed the unused generic POST helper that only supported that upload path.
- Removed the commented-out `url.geo` call and unused `URL` instance from
  `AppDelegate`.
- Extended `scripts/check_ios_project.py` to reject hardcoded coordinate upload
  endpoints and helpers.
- Updated README, VISION, and CHANGES.

## Verification

- `python3 scripts/check_ios_project.py`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add explicit privacy notes for Twitter-derived map annotations and profile
  images.
- Move hardcoded supplemental demo handles into a documented local
  configuration file.
