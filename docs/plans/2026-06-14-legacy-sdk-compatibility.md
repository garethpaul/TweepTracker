# Legacy SDK Compatibility Boundary

## Status: Planned

## Context

The repository contains Swift 2-era application source, iOS 8.0/8.1
deployment settings, and vendored TwitterKit, Fabric, and Crashlytics binaries.
The current README names the project as legacy but does not give contributors
an actionable boundary between static maintenance and a live build.

## Priority

Document the checked-in toolchain and API limitations so contributors do not
mistake portable static verification for current Xcode, Twitter API, login,
map, or crash-reporting compatibility.

## Requirements

- Record the iOS 8.0/8.1 project settings and Swift 2-era source boundary.
- Identify the vendored TwitterKit, Fabric, and Crashlytics integration as
  historical and unsupported by the portable gate.
- State that live login/API behavior requires local credentials and a
  compatible historical Apple toolchain, neither of which is supplied.
- Preserve the credential-free static baseline and prohibit tracked secrets.
- Add fail-closed documentation contracts and hostile mutations.

## Verification

- repository and external-directory `make check`
- hostile deployment-floor, Swift-era, vendored-SDK, live-API, credential,
  documentation, and plan-status mutations
- final artifact, credential, exact-diff, and hosted static audits

## Scope Boundary

This change does not modernize Swift, replace retired SDKs, add credentials,
claim a working Twitter API integration, or alter application behavior.
