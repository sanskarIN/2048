# Release Qualification

2048 Nova separates automated release-candidate verification from real-device and assistive-technology qualification. A green CI run is required, but it is not by itself sufficient evidence for a stable `1.0.0` release.

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

Before publishing `1.0.0`, run the strict stable gate:

```bash
dart run tool/release_readiness.dart --stable
```

Stable mode exits with a failure unless all of the following are true:

- `pubspec.yaml` is version `1.0.0` (an optional build suffix is allowed);
- `CHANGELOG.md` contains a `## [1.0.0]` release section;
- every required qualification item in `docs/release_qualification.json` has status `passed`;
- every passed item contains non-empty evidence;
- every passed item contains a valid ISO-8601 `updatedAt` timestamp;
- the candidate value in the qualification manifest exactly matches the package version;
- all required release, support, security, roadmap, CI, and continuity files exist and are non-empty.

This intentionally makes it difficult to accidentally promote an unqualified release candidate simply by changing the version number.

## Evidence manifest

The source of truth for manual qualification state is:

```text
docs/release_qualification.json
```

The current schema version is `1`. Each entry has:

- `id` — stable machine-readable check identifier;
- `title` — human-readable qualification scope;
- `status` — one of `pending`, `passed`, or `blocked`;
- `evidence` — concise evidence that another maintainer can verify;
- `updatedAt` — ISO-8601 timestamp for the latest qualification result.

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
  "updatedAt": "2026-08-16T12:30:00+05:30"
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
11. Real browser, clipboard, file-provider, and email-handler behavior.
12. Native splash and launcher-icon presentation.
13. Distribution signing/provisioning, package metadata, privacy information, and store metadata.

The detailed acceptance boundary remains in `ROADMAP.md`; feature-specific manual procedures remain in the relevant documents such as `ACCESSIBILITY.md`, `BACKUP_AND_RESTORE.md`, `FILE_BACKUPS.md`, `CHALLENGE_CODES.md`, and replay documentation.

## CI behavior

The primary CI workflow now performs all of the following on pushes and pull requests targeting `main`:

```text
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

The CI gate intentionally runs candidate mode, not `--stable`, while the project is still on the `0.9.x` release-candidate line.

## Stable-release sequence

When every real-world qualification item is genuinely complete:

1. Update each manifest item to `passed` with verifiable evidence and an ISO-8601 timestamp.
2. Resolve every release-blocking defect discovered during qualification.
3. Change `pubspec.yaml` to the final `1.0.0` version/build number.
4. Change the manifest `candidate` field to exactly the same version.
5. Move the final user-facing entries from `Unreleased` into a `## [1.0.0]` changelog section.
6. Update release notes, privacy/store metadata, `ROADMAP.md`, and `what_changed.md`.
7. Run the full normal CI suite.
8. Run `dart run tool/release_readiness.dart --stable` and require a zero exit code.
9. Build and review final distribution artifacts from the exact release commit.
10. Tag and publish only that qualified commit.

A stable tag should never be used as a substitute for the evidence above.
