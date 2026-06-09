# Profile Image Completion Guard

## Status: Completed

## Context

`TweepPicture` drives map annotation creation after the coordinate lookup
succeeds. The list and timeline helpers already complete with empty results on
request failures, but profile-image lookup could skip completion when request
setup failed, transport failed, or the Twitter payload lacked a
`profile_image_url`.

## Objectives

- Keep map annotation flow from hanging on profile-image failures.
- Return an empty profile-image URL when no usable image URL is available.
- Extend static project checks so profile-image lookup completion remains
  covered by `make check`.

## Work Completed

- Added an empty fallback result in `TweepPicture`.
- Completed profile-image lookup after JSON parsing whether or not an image URL
  was found.
- Completed request setup and transport error paths with an empty result.
- Extended `scripts/check_ios_project.py` to require the completion guard.
- Updated README, VISION, and CHANGES.

## Verification

- Negative check before implementation:
  `make check` failed with
  `profile image lookup must keep an empty fallback result`.
- `python3 scripts/check_ios_project.py`
- `make check`
- `git diff --check`

## Follow-Up Candidates

- Add a placeholder annotation image for empty profile-image URLs.
- Add simulator-backed verification when a matching Xcode environment is
  available.
