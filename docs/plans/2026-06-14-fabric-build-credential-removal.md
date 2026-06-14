# Fabric Build Credential Removal

## Status: Completed

## Context

The application target contained a legacy Fabric upload shell build phase with
credentials embedded directly in `project.pbxproj`. This conflicts with the
repository policy that Twitter and Fabric credentials remain local and
untracked.

## Scope

- Remove the Fabric upload shell phase from the application target and delete
  its PBX object.
- Preserve the vendored Fabric, Crashlytics, and TwitterKit framework files as
  historical compatibility artifacts.
- Add a fail-closed static contract that rejects both the Fabric upload command
  and any PBX shell-script build phase.
- Document that current-tree removal does not revoke the historical credential
  or remove it from Git history.

## Verification Plan

- Run `make check` from the repository and an external directory.
- Prove mutations restoring either the Fabric command or a shell-script build
  phase are rejected.
- Audit the exact diff, generated artifacts, and changed lines for secrets.
- Use the exact pushed head for hosted check and code-scanning evidence.

## Verification

- Repository and external-directory `make check` passed with eight static
  project checks; iOS build and XCTest execution were skipped because this
  Linux host does not provide `xcodebuild`.
- Two isolated hostile mutations were rejected: one restored the Fabric upload
  command and one restored the PBX shell-script build-phase marker.
- Final current-tree credential, generated-artifact, changed-line secret,
  whitespace, and exact-diff audits passed.
- Hosted checks and code scanning remain the authority for the exact pushed
  head.

## Scope Boundary

This change does not modernize Swift, replace retired SDK binaries, rewrite Git
history, or claim that the historical Fabric integration remains usable. Any
still-valid credential must be revoked through the service owner separately.
