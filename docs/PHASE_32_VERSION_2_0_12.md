# Phase 32 — Version 2.0.12 Migration and Release-Contract Hardening

Date: **2026-08-19**

## Scope

Phase 32 moves 2048 Nova from the Version 1.5 release-candidate line to **Version 2.0.12** without weakening the repository's fail-closed qualification model.

The visible semantic version is:

```text
2.0.12
```

The Flutter package/build version is:

```text
2.0.12+2012
```

The `+2012` suffix is the platform build number. It is intentionally distinct from the user-facing marketing version.

## Source-controlled version surfaces

Phase 32 aligns:

- `pubspec.yaml` — `2.0.12+2012`;
- `lib/core/constants/project_info.dart` — `2.0.12`;
- `windows/runner/Runner.rc` fallback metadata — `2,0,12,2012` and `2.0.12`;
- `docs/release_qualification.json` candidate — `2.0.12+2012`;
- `ROADMAP.md` — current/stable target `2.0.12`;
- `docs/RELEASE_QUALIFICATION.md` — Version 2.0.12 stable-promotion procedure;
- `tool/release_readiness.dart` — exact Version 2.0.12 release contract;
- `test/release_readiness_cli_test.dart` — Version 2.0.12 candidate/stable/rejection fixtures.

## Release-gate behavior

The release-readiness CLI now reports `releaseTarget: 2.0.12` and accepts only `2.0.12` with an optional numeric build suffix.

It rejects:

- the previous `1.5.x` release line;
- unrelated `2.0.x` patch versions;
- package/qualification-candidate mismatch;
- missing canonical manual qualification IDs;
- malformed or incomplete passed evidence;
- stable promotion without a `## [2.0.12]` changelog section;
- stable promotion while any real-world qualification item remains incomplete.

## Qualification state

The live qualification manifest remains **0/13** passed.

No Phase 32 version or documentation change marks any of these as complete:

- physical Android/iOS validation;
- responsive/input validation on representative targets;
- assistive-technology qualification;
- long-session qualification;
- Auto Play real-target qualification;
- Challenge Code real-target qualification;
- Move Replay real-target qualification;
- Full Replay Archive real-target qualification;
- Game Backup real-handler qualification;
- external browser/clipboard/file/email/PWA handler qualification;
- native branding review;
- signing/provisioning/distribution/store metadata review.

## Historical evidence boundary

The last previously accepted complete CI/native evidence belongs to the earlier Version 1.5 source state:

```text
CI: 32018055661
Tests: 235/235
Dart files formatter-clean: 106
Native matrix: 32015893841
```

Those results are retained as historical evidence only. They are not automatically re-labeled as Version 2.0.12 verification.

A complete maintained Version 2.0.12 formatter/analyzer/test/Web/native result must be observed before a newer full evidence baseline is recorded.

## Continuity preservation

Phase history is preserved in:

- `what_changed_archive_phase_00_30.md` — Phases 0–30;
- `what_changed_archive_phase_31.md` — complete Phase 31 status/PWA hardening record;
- `what_changed.md` — active Phase 32 continuity.

## Open blockers retained

Issue #10 remains an intentional Android toolchain deferral. The repository keeps the known-good AGP 9.1.0 baseline until a controlled release-build experiment proves the previously reproduced AGP 9.3.x/JDK-17 lint failure is resolved.

Issue #12 remains a repository-settings blocker. Tracked source cannot enable branch protection/rulesets by itself; `main` must be protected in GitHub repository settings before that issue can be closed.

## Verification commands

Maintainers should run:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

Native platform builds should then be run through the maintained Platform Builds workflow.

## Stable-release rule

Do not tag or publish Version 2.0.12 as a qualified stable release until:

1. the full maintained automated gate is green on the exact release commit;
2. all 13 real-world qualification checks contain genuine passed evidence and explicit-timezone timestamps;
3. release-blocking issues are resolved or deliberately documented as non-blocking;
4. the Version 2.0.12 changelog/release notes are finalized;
5. `dart run tool/release_readiness.dart --stable` exits successfully on that exact commit;
6. final signed/distribution artifacts are reviewed from that same source state.
