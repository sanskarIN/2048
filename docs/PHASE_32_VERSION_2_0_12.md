# Phase 32 — Version 2.0.12 Migration and Final Source Completion

Date: **2026-08-19**

## Final phase result

Phase 32 moves 2048 Nova from the historical Version 1.5 candidate line to **Version 2.0.12** and closes the active source-feature roadmap for the declared offline-first puzzle-game scope.

```text
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
Source scope: feature-complete
Manual real-world qualification: 0/13 recorded passed evidence
```

Source completion and qualified stable distribution are separate. Phase 32 completes the tracked source/docs/tools/tests scope; it does not fabricate physical-device, accessibility, external-handler, signing/provisioning, branding, PWA-install, or store evidence.

## Version migration

Source-controlled release surfaces are synchronized:

- `pubspec.yaml` → `2.0.12+2012`;
- `ProjectInfo.version` → `2.0.12`;
- Windows fallback numeric version → `2,0,12,2012`;
- Windows fallback string version → `2.0.12`;
- release qualification candidate → `2.0.12+2012`;
- release-readiness target → `2.0.12`;
- security/release/checklist/dependency/maintainer documentation → Version 2.0.12 current-state language;
- release-readiness, timestamp, repository-integrity, qualification-status, qualification-recorder, source-completion, Android-distribution, and current-state fixtures → Version 2.0.12 expectations.

The release-readiness gate rejects the old line and unrelated patch versions, requires candidate/package consistency, retains the canonical 13 real-world checks, and keeps stable promotion fail-closed.

## Hidden migration drift corrected

Version identity previously appeared outside `pubspec.yaml`. Phase 32 corrected stale assumptions in release timestamp fixtures, repository-integrity security assertions, qualification status/recorder fixtures, release-gate documentation, release checklist state, security policy, dependency policy, current-release state tests, and maintainer tooling.

This prevents the Version 2.0.12 candidate from failing for unrelated old-version assertions or presenting historical Version 1.5 automation as current-head evidence.

## Final feature-complete source scope

The completed 2.0.12 source includes:

- deterministic 2048 rules/RNG and validated persistence;
- ten game modes;
- save/resume and bounded deterministic Undo;
- Daily Challenge;
- statistics, achievements, streaks, and trusted per-mode records;
- read-only deterministic Hint;
- isolated Heuristic/bounded-Expectimax Auto Play Demo and solver benchmark;
- bounded Move Replay;
- portable spectator-only Full Replay Archives;
- portable Game Backup with persistent unranked-import isolation;
- seeded Challenge Codes with local QR rendering;
- English/Hindi localization;
- accessibility controls and semantics;
- themes, palettes, high contrast, reduced motion, and optional sound/haptics;
- Android, iOS, Web/PWA, Windows, macOS, and Linux runners;
- Android APK+AAB and native/Web release-build paths;
- complete open-source/release/security/privacy/support/build/development documentation;
- repository-owned release, qualification, integrity, source-completion, and solver tooling.

`ROADMAP.md` now explicitly has **no active post-2.0.12 feature backlog**. Previously optional ideas are non-goals unless a future release deliberately adopts them.

## Final completion audit

Added:

- `docs/FINAL_2_0_12_SOURCE_AUDIT.md` — final source verdict and release-boundary record;
- `docs/MAINTENANCE_POLICY.md` — post-completion maintenance/new-release rules;
- `tool/source_completion_audit.dart` — machine-enforced feature-completion contract;
- `test/source_completion_audit_cli_test.dart` — process-level fail-closed fixtures;
- `docs/SOURCE_COMPLETION_AUDIT.md` — audit contract and maintenance guidance.

Permanent CI runs:

```bash
dart run tool/source_completion_audit.dart --json
```

in addition to the existing repository audit and release gates.

The source-completion audit verifies exact package/candidate identity, final completion documents, final roadmap/no-active-backlog markers, current-doc version drift, and unresolved product TODO/FIXME line comments under `lib/`.

## Repository audit expansion

`tool/repository_audit.dart` now requires the final completion audit/policy/guide/tool and preserved pre-2.0.12 changelog archive as permanent repository assets.

Audit fixtures were expanded accordingly while retaining exact version, PWA, local-link, and temporary-helper fail-closed coverage.

## Android distribution artifact guard

The maintained Platform Builds workflow produces both Android distribution formats:

```text
APK: build/app/outputs/flutter-apk/app-release.apk
AAB: build/app/outputs/bundle/release/app-release.aab
```

It also generates SHA-256 sidecars for both and uploads all four files in the `nova-2048-android-release` qualification artifact.

`test/android_distribution_workflow_test.dart` fails if a future workflow edit silently drops the APK build, Play Store AAB build, either checksum, either uploaded payload, or the fail-closed artifact policy.

This is source/workflow regression protection only. It does not prove that a production-signed AAB has been accepted by Google Play.

## Changelog preservation and cleanup

The previous long development changelog is preserved verbatim at:

- `CHANGELOG_ARCHIVE_PRE_2_0_12.md`

The active `CHANGELOG.md` now describes the Version 2.0.12 source-complete candidate without mixing historical Version 1.5 current-state statements into present release status.

Historical continuity is also preserved in:

- `what_changed_archive_phase_00_30.md`;
- `what_changed_archive_phase_31.md`;
- historical phase verification files.

## Dependency final-freeze decision

The final source freeze is compatibility-first rather than freshness-only.

At the 2026-08-19 audit point, the project intentionally retains its validated dependency surface. A newer `file_picker 11.0.3` patch exists, but it is not required to fix a known 2.0.12 product defect and would require a fresh affected-platform qualification cycle. It is therefore future maintenance, not unfinished 2.0.12 work.

Future dependency/toolchain changes must identify a concrete reason, change the smallest coherent surface, and re-run all affected automated/native qualification.

## Android toolchain decision

Version 2.0.12 retains the accepted:

```text
AGP 9.1.0
Kotlin Android 2.4.10
Gradle 9.7.0
JDK 17
```

baseline.

The previous AGP 9.3.x/JDK-17 release-lint experiment remains useful compatibility history, but a newer AGP is not required product functionality. Future AGP changes are maintenance experiments that must pass release lint and the native matrix without weakening gates.

## Formatter evidence

After the Version 2.0.12 migration, repository-owned Format Dart automation produced:

```text
a2372253f5eb4dde16339e6c913e8581408311fc
style: format Dart sources tests and tools
```

This is positive formatter/parse evidence for the then-current Dart tree. It is not substituted for a complete analyzer/test/Web/native workflow result.

## Automated evidence boundary

The latest previously accepted complete CI/native evidence remains the historical Version 1.5 baseline:

```text
CI run: 32018055661
Tests: 235/235
Dart files formatter-clean: 106
Native matrix run: 32015893841
```

Those results remain historical until a complete maintained Version 2.0.12 verification result is actually observed and recorded. Phase 32 does not relabel older run IDs as evidence for a newer head.

## Real-world qualification remains external

The live manifest remains **0/13** because these require genuine representative environments:

1. physical Android gameplay/lifecycle/save/resume;
2. physical iOS gameplay/lifecycle/save/resume;
3. real touch/orientation/keyboard/focus/responsive layout;
4. TalkBack/VoiceOver/Narrator/browser screen-reader qualification including Hindi/large text;
5. long-session Daily/timed/move-limit/Undo/win-continue behavior;
6. real-target Auto Play behavior/performance/accessibility;
7. real-target Challenge Code QR/clipboard/manual-entry/determinism/accessibility;
8. real-target Move Replay behavior/accessibility;
9. real-target Full Replay Archive behavior/long-replay/accessibility;
10. real clipboard/file/document-provider Game Backup behavior;
11. browser/PWA/clipboard/file/email external handlers;
12. native splash/icon presentation;
13. signing/provisioning/package/privacy/store metadata.

They are stable-distribution qualification, not missing source features.

## Repository-settings boundary

`main` branch protection/rulesets are GitHub repository settings and cannot be implemented by tracked source alone. The source includes CI, CODEOWNERS, dependency review, workflow security, and documented repository-setting guidance; the setting itself remains an external repository-governance action until enabled.

## Verification commands

Maintainers should run or require the maintained CI equivalent of:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

Native platform builds then cover Android APK+AAB, Linux, Windows, macOS, and unsigned iOS on the maintained toolchain baseline.

## Stable-release rule

Do not tag or publish Version 2.0.12 as a qualified stable distribution until:

1. the full maintained automated gate is green on the exact release commit;
2. all 13 real-world qualification checks contain genuine passed evidence and explicit-timezone timestamps;
3. any release-blocking defect is resolved;
4. final release notes/privacy/store metadata are ready;
5. `dart run tool/release_readiness.dart --stable` exits successfully on the exact intended tag commit;
6. final signed/distribution artifacts are reviewed from that same source state.

## Phase 32 final source verdict

Within the declared Version 2.0.12 scope:

- active feature implementation is complete;
- package/runtime/platform/release metadata is synchronized;
- final completion/maintenance/audit contracts are source-controlled;
- active changelog and documentation index are current;
- old history is preserved rather than deleted or relabelled;
- Android APK/AAB distribution source paths are guarded;
- temporary phase-finalizer helpers are forbidden;
- stable promotion remains fail-closed on genuine external evidence.

Any future source change should be treated as maintenance, a defect/security correction, or a deliberately scoped new release—not continuation of an unfinished Version 2.0.12 feature list.
