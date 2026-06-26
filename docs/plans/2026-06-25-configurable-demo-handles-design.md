# Configurable Demo Handles Design

Status: Completed

## Evidence

- `location_tracker/FindTweeps.swift` appends five supplemental Twitter handles
  directly in production source after the legacy list-members response.
- `location_tracker/Info.plist` is already the app target's checked-in runtime
  configuration surface and requires no new resource or loading mechanism.
- `VISION.md` explicitly prioritizes replacing hardcoded supplemental handles
  with configurable demo data while preserving the legacy Swift 2 boundary.

## Options

1. **Info.plist array (recommended).** Move the existing demo handles to a
   `SupplementalTwitterHandles` array, normalize it through one pure Swift
   helper, and append only accepted values. This preserves sample behavior,
   keeps configuration visible, and avoids new UI or resource wiring.
2. **Separate bundled plist.** Clearer separation, but adds project resource
   membership and another failure mode without improving this small sample.
3. **Runtime settings UI or user defaults.** More flexible, but far beyond the
   roadmap request and difficult to validate on the preserved toolchain.

## Design

`FindTweeps` reads `SupplementalTwitterHandles` from the main bundle. A pure
normalizer accepts only an array of strings, trims surrounding whitespace,
rejects empty or malformed handles, enforces the historical 15-character
ASCII letter/digit/underscore boundary, and deduplicates case-insensitively
while retaining the first spelling and order. The checked-in plist contains the
five existing demo handles, so the visible sample result does not change.

The unit-test target documents normalization behavior. Portable repository
contracts reject hardcoded supplemental appends, missing plist configuration,
or bypassing the normalizer. No live Twitter request or device behavior is
required for validation.

Validation is performed through `make check`, including static plist/source
contracts, review contracts, and hostile mutations; legacy Xcode execution
remains a hosted or historical-toolchain boundary.
