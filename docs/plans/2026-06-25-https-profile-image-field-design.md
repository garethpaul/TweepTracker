# HTTPS Profile Image Field Design

status: completed

## Problem

`TweepPicture` reads `profile_image_url` from the Twitter user object, while
the profile-image downloader rejects every non-HTTPS URL. The X API v1 user
object exposes `profile_image_url_https` specifically for HTTPS avatar
delivery and documents the non-HTTPS field as deprecated. A valid user lookup
can therefore produce an avatar URL that the app immediately refuses to load.

## Evidence

- X Developer Platform user-object documentation describes
  `profile_image_url_https` as the HTTPS profile-image URL.
- The same documentation marks `profile_image_url` deprecated and notes that
  profile images are available through the HTTPS field.
- `URL.downloadImage` already enforces HTTPS before creating a request.

## Options

1. Rewrite `http` avatar URLs to `https` in the downloader. This guesses that
   every supplied host supports TLS and weakens the parser's transport
   contract.
2. Accept both fields and prefer HTTPS. This retains a deprecated fallback
   that the downloader cannot use.
3. Read only `profile_image_url_https`. This follows the API contract and
   preserves the downloader's fail-closed HTTPS policy.

## Decision

Use option 3. Require the parser to select `profile_image_url_https`, reject
the deprecated field in portable source checks, and add a hostile mutation
that swaps the parser back to `profile_image_url`.

## Validation

- Demonstrate RED by adding the HTTPS-field contract before changing Swift.
- Run the portable checker and review-contract mutation suite.
- Run `make check` and the repository's focused Make verification gates.
