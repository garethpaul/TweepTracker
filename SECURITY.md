# Security Policy

## Supported Versions

The supported security scope for `TweepTracker` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: iOS app that tracks Tweeps around the world.

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/TweepTracker` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- Popped map controllers invalidate refresh callbacks, cancel visible avatar
  tasks, detach their map delegate, and remove their navigation logo overlay.
- This repository appears to be an Apple platform application or Swift sample. The active security scope is the code and documentation on the default branch.
- Review found authentication, token, or session-related code paths; changes in those areas should receive security-focused review before merge.
- Review found external API integrations or credential-adjacent configuration; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Keep Twitter/Fabric credentials out of tracked plist and Xcode project files,
  do not add shell-script build phases, and do not add broad App Transport
  Security exceptions.
- The legacy SDK compatibility boundary treats the vendored TwitterKit,
  Fabric, and Crashlytics binaries as historical artifacts; live use requires
  local untracked credentials and is not covered by portable verification.
- The historical Fabric upload build phase has been removed from the current
  tree. Removing it does not revoke or erase the two values retained in Git
  history; service owners must revoke both historical Fabric credentials at
  the provider, review provider activity, or delete the retired Fabric app.
- Remote profile-image requests and final responses must use HTTPS and pass
  status, image MIME type, size, and decode validation before display.
- Reused map pins must cancel obsolete profile-image tasks before accepting a
  new annotation while retaining the annotation-identity callback guard.
- Profile-image callbacks must match the pin's active request generation before
  releasing task ownership or changing the rendered avatar.
- Placemark fields and device coordinates must remain out of diagnostic logs.
- Runtime error log privacy requires Twitter request, SDK, and authentication
  failures to use existing fallback behavior without interpolating raw error
  objects into device or CI logs.
- Map refresh generation ownership requires list, location, picture, and
  delayed reveal callbacks to match the controller's current refresh before
  mutating annotations or loading UI state.
- Trusted portable verification starts at `./scripts/run-make.sh check`. The
  wrapper resolves its physical checkout with fixed tools, accepts only exact
  `check|lint` targets, clears `MAKEFILES`, `MAKEFLAGS`, `MFLAGS`,
  `MAKEOVERRIDES`, and `GNUMAKEFLAGS`, and preserves literal `PYTHON` and
  `RUN_LEGACY_XCODE=0|1` environment overrides. Direct Make options, startup
  files, and extra `-f` files are pre-wrapper caller authority; direct
  `make check` is therefore not the trusted entrypoint.
- Twitter timeline coordinates must reject Boolean, non-finite, and
  out-of-range values, then reduce accepted coordinates to two decimal places
  before map display. The app must not request device-location authorization.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Review found database, model, query, or persistence-related code; changes in those areas should receive security-focused review before merge.
- No primary dependency manifest was detected in the repository root. If dependencies are added later, include a manifest and prefer reproducible installation instructions.
- GitHub Actions runs `./scripts/run-make.sh check` on fixed Ubuntu 24.04 with read-only
  repository permissions. Checkout credentials are not persisted, and the
  workflow does not execute or validate the retired vendored SDK binaries.

## Mobile Privacy Notes

If this project requests device permissions such as location, camera, microphone, contacts, Bluetooth, health data, or local storage access, reports should describe the permission involved and whether sensitive data can be accessed, persisted, or transmitted unexpectedly. Please avoid testing against real third-party user data or accounts you do not control.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
