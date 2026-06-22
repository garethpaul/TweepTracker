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
- Added `scripts/run-make.sh` as the trusted fixed-target boundary used by
  hosted checks. It resolves the physical checkout, clears all five Make
  control variables, and accepts only exact `check|lint` targets.
- Reproduced real `-n/--eval`, `-i/--eval`, `GNUMAKEFLAGS`, `MAKEFILES`, and
  earlier/later `-f` authority before proving the wrapper excludes them.

## Scope Boundaries

No application source, vendored framework, credential file, live provider,
location service, Xcode project, workflow, publishing, or deployment changed.
Direct GNU Make invocation remains pre-wrapper caller authority: startup files,
`GNUMAKEFLAGS`, command-line options, and earlier or later caller-supplied `-f`
files can execute or alter behavior before this Makefile is parsed.
