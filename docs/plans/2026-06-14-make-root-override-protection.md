# Make Root Override Protection

## Status: Completed

## Context

The Makefile derives an absolute repository root so static and Xcode aliases
work from any current directory. Its ordinary GNU Make assignment can be
replaced by an environment or command-line `ROOT`, redirecting the repository
checker and Xcode working paths to another tree while a command appears to
verify this checkout.

Python selection is intentionally configurable. Repository ownership is not:
every source, project, test, workflow, and evidence path must remain anchored
to the checkout containing the invoked Makefile.

## Requirements

- Protect the derived repository root from environment and command-line
  reassignment.
- Preserve explicit `PYTHON` overrides and all five public aliases.
- Prove repository and external working-directory invocations remain anchored
  under hostile root assignments.
- Add mutation-sensitive contracts for the declaration, assignment count and
  order, aliases, checker/Xcode paths, README index, and completed plan.
- Preserve Swift, networking, map annotation, privacy, Xcode, workflow, and SDK
  behavior.

## Approach

Apply GNU Make's `override` directive only to the existing immediate root
assignment. Keep it before `PYTHON ?=` and extend the canonical iOS checker with
exact structural contracts. Use bounded dry-run cases for Make precedence and
retain hosted event checks as the native branch authority.

## Implementation Units

### Protect repository path ownership

- Update `Makefile` so exactly one protected root declaration owns repository
  paths while Python remains configurable.

### Add adversarial contracts

- Extend `scripts/check_ios_project.py` with declaration-count, ordering, alias,
  checker/Xcode-path, README, and plan requirements.
- Run all five aliases from repository and external directories under hostile
  environment and command-line root assignments.
- Reject declaration, duplication, ordering, alias, path, documentation, and
  plan-state mutations.

### Record completed evidence

- Index this plan from `README.md`.
- Mark it completed only after focused, mutation, full static, review, artifact,
  secret, and exact-diff validation succeeds.

## Risks And Mitigations

- Protecting the interpreter would prevent supported validation customization.
  Only `ROOT` becomes protected; `PYTHON ?=` remains unchanged and tested.
- A declaration-only assertion could miss a later reassignment or alias bypass.
  Count all assignments and require every alias and repository-owned path.
- Local Linux cannot compile the historical iOS project. Run the complete
  static gate locally and retain both hosted push and pull-request checks as the
  exact-head branch authority.

## Scope Boundaries

This change does not modify Swift logic, image transport, task cancellation,
request generations, map rendering, privacy behavior, project settings,
workflow policy, dependencies, SDK versions, or deployment behavior.

## Work Completed

- Protected the derived repository root with GNU Make's `override` directive
  while preserving configurable Python selection.
- Added declaration-count, ordering, alias, checker/Xcode-path, README, and plan
  contracts to the canonical iOS checker.
- Indexed the completed evidence without changing Swift, project, workflow,
  privacy, networking, or map behavior.

## Verification Results

- All five public aliases passed dry-run verification from repository and
  external working directories under hostile environment and command-line
  `ROOT` assignments, for 20 bounded cases; explicit `PYTHON` overrides remained
  effective.
- Eight declaration protection, duplicate assignment, ordering, alias,
  checker-path, README, missing-plan, and incomplete-plan mutations were
  rejected.
- The completed `make check` gate passed the full static project contract and
  documented no-Xcode test/build paths from the repository and an external
  working directory.
- Hosted push and pull-request checks remain the exact-head branch authority.
- Plan-aware correctness, build-integrity, iOS, privacy, testing,
  maintainability, reliability, and project-standards review found no
  actionable findings.
- Exact diff, protected Swift/project/workflow/framework path,
  generated-artifact, changed-line secret, and whitespace audits passed.
