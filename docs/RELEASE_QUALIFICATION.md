# Release Qualification

2048 Nova separates automated release-candidate verification from real-device and assistive-technology qualification. A green CI run is required, but it is not by itself sufficient evidence for a stable `2.0.12` release.

## Machine-enforced gate

Run the normal release-candidate check from the repository root:

```bash
dart run tool/release_readiness.dart
```

For machine-readable output:

```bash
dart run tool/release_readiness.dart --json
```

The normal candidate check validates the release metadata, required repository files, the qualification-manifest schema, candidate-version consistency, and the exact set of required manual checks. Pending manual checks are reported as warnings so normal release-candidate CI can continue while qualification is in progress.

Before publishing `2.0.12`, run the strict stable gate:

```bash
dart run tool/release_readiness.dart --stable
```

Stable mode exits with a failure unless all of the following are true:

- `pubspec.yaml` is version `2.0.12` with an optional numeric build suffix;
- `CHANGELOG.md` contains a `## [2.0.12]` release section;
- every required qualification item in `docs/release_qualification.json` has status `passed`;
- every passed item contains non-empty evidence;
- every passed item contains a valid ISO-8601 `updatedAt` timestamp with an explicit UTC (`Z`) or numeric offset;
- the candidate value in the qualification manifest exactly matches the package version;
- all required release, support, security, roadmap, CI, and continuity files exist and are non-empty.

The current Flutter package/build candidate is `2.0.12+2012`; the visible semantic version is `2.0.12`. The `+2012` component is the platform build number and does not change the marketing version.

This intentionally makes it difficult to accidentally promote an unqualified release candidate simply by changing the version number.

## Evidence manifest

The source of truth for manual qualification state is:

```text
docs/release_qualification.json
```

To inspect the current state without mutation, run `dart run tool/release_qualification_status.dart --pending-only` (or add `--json`) as documented in [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md). To reduce hand-editing mistakes when evidence is genuinely available, maintainers may use `dart run tool/record_release_qualification.dart --list` and the guarded mutation commands documented in [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md). Neither tool performs or infers a real-world check: the reporter is read-only, and the recorder only validates and stores evidence explicitly supplied by the maintainer.

The current schema version is `1`. Each entry has:

- `id` — stable machine-readable check identifier;
- `title` — human-readable qualification scope;
- `status` — one of `pending`, `passed`, or `blocked`;
- `evidence` — concise evidence that another maintainer can verify;
- `updatedAt` — ISO-8601 timestamp for the latest qualification result, with an explicit UTC (`Z`) or numeric timezone offset.

Timezone-less evidence timestamps such as `2026-08-19T07:30:00` are rejected because they do not identify one unambiguous instant across machines and time zones. Use values such as `2026-08-19T02:00:00Z` or `2026-08-19T07:30:00+05:30` instead.

Do not mark an item `passed` merely because a widget or unit test covers similar behavior. These entries exist specifically for checks that require representative real environments or external handlers.

## Recording evidence

Use evidence that identifies what was actually exercised. Good evidence can include:

- device model and OS version;
- browser and browser version;
- orientation or input method used;
- assistive technology and language used;
- build or commit SHA tested;
- relevant workflow run or artifact identifier;
- short result notes and any issue number created for a defect.

Example after a real check has passed:

```json
{
  "id": "android-device",
  "title": "Physical Android gameplay, lifecycle, save, and resume",
  "status": "passed",
  "evidence": "Pixel device, Android release build from commit <sha>: new game, background/foreground, process restart, save/resume, Undo, and restart passed.",
  "updatedAt": "2026-08-19T07:30:00+05:30"
}
```

Do not copy that example as evidence unless those checks were actually performed.

## Required manual qualification set

The manifest and gate require evidence for all of these boundaries:

1. Physical Android gameplay/lifecycle/save-resume.
2. Physical iOS gameplay/lifecycle/save-resume.
3. Representative touch, orientation, keyboard, focus, and responsive-layout behavior.
4. VoiceOver, TalkBack, Narrator or browser-screen-reader behavior, including Hindi and large text.
5. Long-session Daily/timed/move-limit/Undo/win-continue behavior.
6. Auto Play strategy switching, pause, responsiveness, localization, and accessibility on real targets.
7. Challenge Code QR/copy/paste/manual-entry/validation/determinism/accessibility using real handlers and external scanners where applicable.
8. Move Replay scrub/play/pause/navigation/accessibility on real targets.
9. Full Replay Archive import/playback/4,096-event-boundary/long-session/accessibility behavior.
10. Game Backup clipboard/file save/open/cancel/round-trip/error/restore behavior using real platform handlers.
11. Real browser, clipboard, file-provider, and email-handler behavior, including deployed PWA installation/lifecycle behavior where applicable.
12. Native splash and launcher-icon presentation.
13. Distribution signing/provisioning, package metadata, privacy information, and store metadata.

The detailed acceptance boundary remains in `ROADMAP.md`; feature-specific manual procedures remain in the relevant documents such as `ACCESSIBILITY.md`, `BACKUP_AND_RESTORE.md`, `FILE_BACKUPS.md`, `CHALLENGE_CODES.md`, `PWA.md`, and replay documentation.

## CI behavior

The primary CI workflow performs the following on pushes and pull requests targeting `main`:

```text
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

The CI gate intentionally runs candidate mode, not `--stable`, while Version 2.0.12 remains under qualification. The qualification status command is also intentionally read-only and non-strict in normal CI: it validates the canonical evidence manifest and prints unfinished checks, while the separate stable readiness command retains fail-closed promotion behavior.

## Stable-release sequence

When every real-world qualification item is genuinely complete:

1. Update each manifest item to `passed` with verifiable evidence and an ISO-8601 timestamp containing explicit `Z` or a numeric timezone offset.
2. Resolve every release-blocking defect discovered during qualification.
3. Keep `pubspec.yaml` on the final `2.0.12` marketing version with the intended numeric build number.
4. Keep the manifest `candidate` field exactly equal to the package version.
5. Move the final user-facing entries from `Unreleased` into a `## [2.0.12]` changelog section.
6. Update release notes, privacy/store metadata, `ROADMAP.md`, and `what_changed.md`.
7. Run the full normal CI suite.
8. Run `dart run tool/release_readiness.dart --stable` and require a zero exit code.
9. Build and review final distribution artifacts from the exact release commit.
10. Tag and publish only that qualified commit.

A stable tag should never be used as a substitute for the evidence above.

## Automated gate regression fixtures

The release gate itself is regression-tested through `test/release_readiness_cli_test.dart` and the focused timestamp fixture in `test/release_evidence_timestamp_test.dart`. The read-only qualification reporter is regression-tested independently through `test/release_qualification_status_cli_test.dart`. Both maintenance CLIs accept `--root=<path>` so tests can construct isolated temporary repository fixtures without mutating the real checkout:

```bash
dart run tool/release_readiness.dart --root=<fixture-path> --json
dart run tool/release_qualification_status.dart --root=<fixture-path> --json
```

The fixture option exists for testability only. It does not turn synthetic metadata into real release evidence. The release-readiness suite exercises Version 2.0.12 candidate success, complete stable success with explicit-offset timestamps, stable refusal with pending evidence, rejection of the old Version 1.5 line, rejection of unrelated 2.0 patch versions, package/manifest candidate mismatch, false `passed` entries without evidence/timestamps, rejection of ambiguous timezone-less passed evidence, and missing required qualification IDs. The status-reporter suite additionally exercises aggregate summaries, pending-only filtering, blocked states, canonical ID enforcement, evidence/timestamp validation, malformed arguments, and its distinct intentional incomplete-state exit code. See [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md) and [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md).

Historical automated evidence remains recorded in [`VERIFICATION.md`](VERIFICATION.md), the phase verification documents, and the continuity archives. The live Version 2.0.12 candidate still reports **0/13** real-world qualification items complete, so strict stable mode correctly remains closed.

## Hosted qualification artifacts

The permanent native build matrix publishes short-lived checksummed outputs documented in [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md). Use those outputs when they help perform a real target check against a known source commit.

Artifact existence, hosted compilation, checksum generation, and upload success **do not** mark any manual manifest item passed. Evidence must still describe what was exercised on the representative real environment. An unsigned iOS artifact is compilation/package evidence only until real signing/provisioning and device/distribution checks are completed.
