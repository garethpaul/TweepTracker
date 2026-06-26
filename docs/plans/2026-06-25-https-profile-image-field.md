# HTTPS Profile Image Field Implementation Plan

status: completed

## Goal

Keep valid Twitter avatar responses compatible with the app's existing
HTTPS-only, bounded profile-image transport.

## Steps

1. Add a source contract requiring `profile_image_url_https`.
2. Reject direct parsing of deprecated `profile_image_url`.
3. Add a hostile mutation restoring the deprecated field.
4. Confirm the new contract fails against the current parser.
5. Switch `TweepPicture` to the documented HTTPS field.
6. Update maintenance documentation and run all portable gates.

## Acceptance Criteria

- `TweepPicture` reads `profile_image_url_https`.
- No production parser reads `profile_image_url` directly.
- The hostile field-regression mutation is rejected.
- `make check`, `make lint`, `make test`, and `make build` pass.
