# Make Authority Hardening

## Status: Completed

## Context

Portable verification protected its root but still accepted Make-syntax Python
values, caller shells, Makefile identity replacement, non-executing flags, and
unbounded legacy-Xcode opt-in values.

## Requirements

- Preserve literal Python overrides and literal `RUN_LEGACY_XCODE=0|1` usage.
- Reject Make-syntax tools, shell/root identity replacement, and skipped gates.
- Run the same authority regression from repository and external directories.
- Keep all Twitter, Fabric, location, credential, network, and legacy SDK paths
  offline and unexecuted.

## Work Completed

- Bound verification roots, shells, interpreter, flags, and legacy-Xcode mode.
- Added executable adversarial regression coverage to `make check`.
- Preserved the documented GNU Make startup and later-`-f` trust boundary.

## Scope Boundaries

No application source, vendored framework, credential file, live provider,
location service, Xcode project, workflow, publishing, or deployment changed.
GNU Make startup files can execute during parsing, and later caller-supplied
`-f` files remain outside this repository authority boundary.
