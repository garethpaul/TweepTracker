# Annotation Image Reuse Guard

Status: Completed

## Goal

Prevent delayed profile image downloads from assigning one Tweep's avatar to a
map pin that has already been reused for another annotation.

## Implementation

- Reuse dequeued pin views instead of replacing them unconditionally.
- Clear stale pin images before starting a new profile image request.
- Skip image loading for annotations that are not `TweepAnnotation` instances.
- Verify annotation identity again before applying an asynchronous image.

## Verification

- `make check`
- Mutation check: removing the annotation identity comparison must fail the
  static project contract.
