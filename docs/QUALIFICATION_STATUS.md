# Release Qualification Status Reporter

`tool/release_qualification_status.dart` is the read-only companion to the release qualification recorder. It turns `docs/release_qualification.json` into a deterministic human-readable or JSON status report without changing any evidence.

## Purpose

The Version 1.5 stable gate requires 13 real-world qualification checks. Most of those checks cannot be truthfully completed by hosted automation because they depend on physical devices, assistive technologies, native handlers, signing/provisioning, or store metadata review.

The status reporter makes that boundary easier to inspect while keeping it fail-closed. It can summarize progress, expose only incomplete checks, validate the recorded manifest shape, and optionally return a distinct non-zero exit code while qualification is incomplete.

## Basic usage

Human-readable report:

```bash
dart run tool/release_qualification_status.dart
```

Machine-readable report:

```bash
dart run tool/release_qualification_status.dart --json
```

Show only pending or blocked check details while preserving the aggregate totals:

```bash
dart run tool/release_qualification_status.dart --pending-only
```

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

Require completion in a maintainer script:

```bash
dart run tool/release_qualification_status.dart --fail-if-incomplete
```

Read a fixture or another checkout:

```bash
dart run tool/release_qualification_status.dart --root=/path/to/2048
```

## Exit codes

- `0` — the manifest is structurally valid and, unless `--fail-if-incomplete` was requested, the report was produced successfully.
- `3` — `--fail-if-incomplete` was requested and one or more canonical checks are still pending or blocked.
- `64` — arguments or qualification evidence are malformed, incomplete, duplicated, unknown, or otherwise invalid.

Pending manual work is not an error in ordinary reporting mode. That is deliberate: CI can report the current state without pretending the stable gate is open.

## JSON output

The JSON form includes:

- `candidate` — the release candidate recorded by the qualification manifest.
- `total` — total canonical checks. Version 1.5 requires 13.
- `passed` — checks with recorded passed evidence.
- `pending` — checks not yet qualified.
- `blocked` — checks with a documented blocker.
- `complete` — `true` only when every canonical check is passed.
- `checks` — check details in manifest order.

When `--pending-only` is used, `checks` omits passed entries but the aggregate `total`, `passed`, `pending`, `blocked`, and `complete` values still describe the full canonical checklist.

## Validation rules

Before reporting status, the tool validates that:

1. `schemaVersion` is `1`.
2. `candidate` is a non-empty string.
3. `manualChecks` is an array containing exactly the 13 canonical Version 1.5 check IDs.
4. IDs are unique and no unknown check IDs are accepted.
5. Every check has a non-empty title and a status of `pending`, `passed`, or `blocked`.
6. `pending` checks contain no stale evidence or timestamp.
7. `passed` and `blocked` checks contain non-empty evidence.
8. `passed` and `blocked` checks contain a valid ISO-8601 timestamp with an explicit `Z` or numeric UTC offset.

These checks help catch accidental manifest damage early. They do not determine whether real-world evidence is truthful; that remains a maintainer responsibility.

## Relationship to the other release tools

Use the three qualification tools for different jobs:

- `tool/release_qualification_status.dart` — read and summarize the recorded state.
- `tool/record_release_qualification.dart` — explicitly record a maintainer-observed result and evidence.
- `tool/release_readiness.dart` — enforce candidate/stable release metadata and the stable fail-closed gate.

A typical qualification loop is:

1. Run the status reporter with `--pending-only`.
2. Perform one listed check on the representative real target.
3. Preserve concrete evidence such as the device/OS/browser context, observed behavior, and relevant artifact or store state.
4. Record the result with `record_release_qualification.dart`.
5. Run the status reporter again.
6. Run `release_readiness.dart --stable --json` only when the entire manual checklist and final stable metadata are complete.

## CI behavior

Permanent CI runs:

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

This validates and publishes the current incomplete-state summary in job logs while allowing expected pending checks. CI separately verifies that the strict stable readiness command remains fail-closed until manual qualification is complete.

## Trust boundary

The reporter is intentionally read-only. It never:

- changes `docs/release_qualification.json`;
- converts a pending or blocked check to passed;
- generates device, accessibility, signing, provisioning, external-handler, or store evidence;
- treats hosted automated tests as a substitute for real qualification.

This preserves the repository rule that stable-release evidence must describe work that was actually performed.
