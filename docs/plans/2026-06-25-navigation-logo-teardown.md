# Navigation Logo Teardown

status: completed

## Problem

Each map controller adds its logo directly to the navigation controller's view.
When a map controller is popped and deallocated, the external superview could
retain that logo indefinitely, leaving duplicate overlays after later map
controllers are created.

## Design

- Remove the owned logo from its superview in `viewDidDisappear` after a
  completed navigation pop, without waiting for `deinit`; keep deallocation
  cleanup as a fallback and preserve cancelled interactive transitions.
- Keep the existing appearance and disappearance animation behavior unchanged.
- Require the teardown in both the static project checker and portable review
  contracts.
- Reject a hostile mutation that clears the property without removing the
  externally retained view.

## Verification

- The focused review contract failed before teardown existed and passed after
  the implementation.
- The hostile logo-removal mutation failed the maintained project checker.
- Root and external-directory `make check` passed.
- Python syntax and `git diff --check` passed.
- Legacy Xcode execution remained disabled locally; no simulator runtime claim
  is made.
