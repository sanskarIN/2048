# 2048 Nova Maintainer Tools

The `tool/` directory contains deterministic, repository-owned command-line utilities used for solver benchmarking, repository integrity, cross-platform support enforcement, source-completion enforcement, and release maintenance. These tools are intended to be run from the repository root with the Dart SDK supplied by the supported Flutter toolchain.

The current release contract is:

```text
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
Source scope: feature-complete
Maintained targets: Android, iOS, Web/PWA, Windows, macOS, Linux
Manual qualification: 0/13 passed
```

## Repository integrity audit

```bash
dart run tool/repository_audit.dart --json
```

Checks required project/open-source/release/workflow files, exact Phase 32 package/runtime/Windows/qualification version consistency, PWA metadata, continuity archives, known temporary maintenance leftovers, and repository-local Markdown destinations. See [`../docs/REPOSITORY_AUDIT.md`](../docs/REPOSITORY_AUDIT.md).

## Cross-platform support audit

```bash
dart run tool/platform_support_audit.dart --json
```

Checks the maintained six-target contract for Android, iOS, Web/PWA, Windows, macOS, and Linux. It verifies required runner files, every release-build command, all platform path triggers in the dedicated build workflow, checksummed Web/PWA qualification packaging, and permanent CI wiring. The command fails closed when any maintained target silently loses its source runner or automated build path.

The process-level regression suite is `test/platform_support_audit_cli_test.dart`. See [`../docs/CROSS_PLATFORM_SUPPORT.md`](../docs/CROSS_PLATFORM_SUPPORT.md) and [`../docs/PLATFORMS.md`](../docs/PLATFORMS.md).

## Source completion audit

```bash
dart run tool/source_completion_audit.dart --json
```

Checks the final Version 2.0.12 completion contract: exact package/candidate version, final source-audit and maintenance documents, feature-complete roadmap/no-active-backlog markers, current documentation version drift, and unresolved product `TODO`/`FIXME` line comments under `lib/`.

It does not replace analyzer/tests, platform builds, or real-device/manual qualification. See [`../docs/SOURCE_COMPLETION_AUDIT.md`](../docs/SOURCE_COMPLETION_AUDIT.md) and [`../docs/FINAL_2_0_12_SOURCE_AUDIT.md`](../docs/FINAL_2_0_12_SOURCE_AUDIT.md).

## Release readiness gate

Candidate mode:

```bash
dart run tool/release_readiness.dart --json
```

Strict stable mode:

```bash
dart run tool/release_readiness.dart --stable --json
```

The candidate gate targets Version `2.0.12` and accepts its numeric Flutter build suffix. The stable form must remain fail-closed until all 13 genuine real-world qualification records and final Version 2.0.12 metadata are complete. See [`../docs/RELEASE_QUALIFICATION.md`](../docs/RELEASE_QUALIFICATION.md) and [`../docs/PHASE_32_VERSION_2_0_12.md`](../docs/PHASE_32_VERSION_2_0_12.md).

## Qualification status reporter

Show the recorded qualification state without mutating evidence:

```bash
dart run tool/release_qualification_status.dart
```

Show only pending and blocked details while preserving the full 13-check summary:

```bash
dart run tool/release_qualification_status.dart --pending-only
```

Produce machine-readable output:

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

Maintainer scripts may add `--fail-if-incomplete` when they intentionally need a distinct non-zero result until all checks pass. The reporter validates the canonical checklist, evidence shape, and explicit timestamps but never changes a status or invents manual evidence. See [`../docs/QUALIFICATION_STATUS.md`](../docs/QUALIFICATION_STATUS.md).

## Qualification evidence recorder

List the current manual checks without mutation:

```bash
dart run tool/record_release_qualification.dart --list
```

Record evidence only after the corresponding representative real-world check has actually been performed. See [`../docs/QUALIFICATION_RECORDER.md`](../docs/QUALIFICATION_RECORDER.md).

## Solver benchmark

Run the deterministic solver smoke/benchmark harness:

```bash
dart run tool/solver_benchmark.dart 8
```

The benchmark compares the isolated Auto Play strategies without touching player saves, statistics, achievements, or Daily Challenge history. See [`../docs/SOLVER_BENCHMARKS.md`](../docs/SOLVER_BENCHMARKS.md).

## Final maintainer verification sequence

Before cutting a release-verification branch, run or require the maintained CI equivalent of this sequence:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/platform_support_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

For changes touching application, platform-runner, or dependency configuration, also require the complete hosted Platform Builds matrix: Android APK+AAB, Web/PWA, Linux, Windows, macOS, and unsigned iOS. A production-signed artifact still requires private local signing inputs and real-device/store qualification documented in the build guides.

## Version-change rule

A future version bump must not update only `pubspec.yaml`. Coordinate at least:

- `pubspec.yaml` package/build version;
- `ProjectInfo.version` marketing version;
- platform fallback metadata where applicable;
- `docs/release_qualification.json` candidate;
- `tool/release_readiness.dart` current release target;
- `tool/repository_audit.dart` exact current version contract;
- `tool/source_completion_audit.dart` completion/version contract when the completed release scope changes;
- release-gate/audit/current-state fixtures;
- README, roadmap, security/release documentation, final audit/maintenance policy, and continuity records.

If the maintained platform set changes, also coordinate `tool/platform_support_audit.dart`, its regression tests, the Platform Builds workflow, and [`../docs/CROSS_PLATFORM_SUPPORT.md`](../docs/CROSS_PLATFORM_SUPPORT.md).

This prevents a partially migrated release line from passing by accident.

## Maintenance rule

These utilities are part of the source-controlled release contract. Changes to them must remain formatter-clean, analyzer-clean, regression-tested where applicable, documented, and compatible with permanent CI. Tool output is automated evidence only; it must never be misrepresented as physical-device, assistive-technology, signing, provisioning, external-handler, PWA/browser, or store-distribution qualification.

After Version 2.0.12 source completion, new product functionality should start a deliberately scoped future release instead of silently weakening the source-completion audit. See [`../docs/MAINTENANCE_POLICY.md`](../docs/MAINTENANCE_POLICY.md).
