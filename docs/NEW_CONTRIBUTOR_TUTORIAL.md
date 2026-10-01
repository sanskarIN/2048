# New Contributor Tutorial — From Zero to a Safe 2048 Nova Change

Current source target: **2.0.12+2012**.

This tutorial gives a new contributor a complete path from installing tools to opening a reviewable pull request without weakening deterministic gameplay, persistence validation, trust boundaries, accessibility, or release evidence.

## 1. Understand the project before editing

2048 Nova is a Flutter/Dart, offline-first, cross-platform 2048 implementation with deterministic domain logic and explicit release/trust boundaries.

Start by reading:

1. [`README.md`](README.md)
2. [`setup/README.md`](setup/README.md)
3. [`DOCUMENTATION_READING_GUIDE.md`](DOCUMENTATION_READING_GUIDE.md)
4. [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md)
5. [`ARCHITECTURE.md`](ARCHITECTURE.md)
6. [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md)
7. [`TESTING.md`](TESTING.md)
8. [`CONTRIBUTING.md`](../CONTRIBUTING.md)

## 2. Install the host tools

At minimum install:

- Git;
- Flutter SDK that satisfies `pubspec.yaml`;
- the Dart SDK bundled with Flutter;
- a code editor such as VS Code or Android Studio.

Target-specific tools:

- Android: Android Studio/SDK + JDK 17 baseline;
- Windows native: Visual Studio Desktop development with C++;
- macOS/iOS: Xcode and CocoaPods where required;
- Linux native: compiler, CMake, Ninja, pkg-config, GTK development libraries.

Use [`setup/TOOL_SUPPORT_MATRIX.md`](setup/TOOL_SUPPORT_MATRIX.md) before deciding that a newer tool should replace a reviewed project pin.

## 3. Verify the workstation

```bash
flutter --version
dart --version
flutter doctor -v
git --version
```

Resolve required `flutter doctor` findings for the targets you intend to build.

## 4. Clone and enter the repository

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
```

Confirm the branch/state:

```bash
git status
git branch --show-current
git log -1 --oneline
```

## 5. Resolve dependencies without changing them accidentally

```bash
flutter pub get
git diff -- pubspec.lock analysis_options.yaml
```

If dependency metadata changed unexpectedly, investigate before coding.

## 6. Establish a clean baseline

Run:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Then:

```bash
dart run tool/release_readiness.dart --json
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

The strict stable gate can remain closed while the 13 real-world checks are pending. That is not a local development failure.

## 7. Create a branch

Use a descriptive branch:

```bash
git switch -c fix/short-problem-name
```

Examples:

```text
fix/custom-preset-rename
feat/future-scoped-feature
accessibility/board-focus
build/android-toolchain-maintenance
docs/linux-setup-correction
```

A new product feature after the completed 2.0.12 scope should be deliberately scoped as a future release rather than smuggled into maintenance.

## 8. Find the correct layer

Use this rule of thumb:

| Change | Typical location |
| --- | --- |
| merge/spawn/game rule | `lib/domain/` |
| persistent schema/store | `lib/data/` + controller/tests |
| session/statistics/trust orchestration | `lib/app/state/` |
| screen/form/navigation | `lib/features/` |
| translation | `lib/core/localization/` |
| theme | `lib/core/theme/` |
| shared UI/guards | `lib/shared/` |
| release/audit CLI | `tool/` |
| platform config | target runner directory |
| CI | `.github/workflows/` |
| docs | `docs/` + continuity/changelog when relevant |

Do not solve a domain defect only in a widget if the underlying rule can still be violated elsewhere.

## 9. Preserve deterministic gameplay

A gameplay rule change should normally have domain-level tests.

Do not introduce uncontrolled randomness into screens. The deterministic random source belongs to the game/session flow so save/resume, Challenge Codes, replay, Daily Challenge, and tests remain reproducible.

## 10. Preserve trust boundaries

Before changing persistence/import/replay/custom/solver behavior, ask:

- Can user-editable portable data write trusted statistics?
- Can imported backup progress become ranked after restart?
- Can a custom board overwrite a built-in mode record?
- Can replay playback mutate the live game?
- Can Auto Play write player records?
- Can Challenge Code input bypass Daily isolation?

If the answer becomes “yes” accidentally, the change is not ready.

## 11. Example: modify Custom Game Builder safely

Suppose you add a preset action.

Relevant files may include:

```text
lib/domain/custom_game_preset.dart
lib/data/custom_preset_store.dart
lib/features/modes/custom_game_builder_screen.dart
test/custom_game_preset_test.dart
test/custom_preset_store_test.dart
test/custom_game_builder_screen_test.dart
docs/CUSTOM_GAME_BUILDER.md
```

Check:

- invalid values rejected before replacement;
- preset count remains bounded;
- duplicate names remain deterministic/case-insensitive;
- clear-all still removes project-owned keys;
- custom-session record isolation remains unchanged;
- Hindi UI remains usable;
- narrow/large-text UI does not overflow.

## 12. Write regression tests with the fix

A good bug fix proves both:

1. the old failure would have been detected;
2. expected nearby behavior still works.

Prefer focused tests over large snapshots that fail for unrelated visual changes.

## 13. UI testing rules

For widget interactions:

- use semantic/widget finders instead of fragile pixel coordinates;
- bring controls fully into view before tapping when the test viewport is scrollable;
- test representative narrow width and text scaling for responsive changes;
- include Hindi where text length/translation behavior matters;
- do not suppress genuine hit-test or overflow failures.

## 14. Persistence testing rules

When adding/changing a stored key:

- define schema/version behavior;
- validate malformed data;
- test corruption recovery;
- bound lists/history;
- test reset/clear behavior;
- test restart persistence;
- document migration/trust impact.

## 15. Portable input testing rules

Portable data is user-controlled input.

Test:

- empty input;
- wrong type/shape;
- unsupported version;
- oversized input;
- invalid numeric bounds;
- malformed timestamp/checksum/event order where relevant;
- successful round trip;
- trust isolation after import/restart.

## 16. Localization changes

Do not hard-code a new player-facing English string into a path that is intended to be localized without adding Hindi/fallback behavior.

Test both supported locales for critical flows.

## 17. Accessibility changes

Review:

- semantic labels;
- keyboard/focus behavior;
- touch target discoverability;
- text scaling;
- narrow/responsive layout;
- contrast;
- reduced motion.

Automated coverage does not replace real TalkBack/VoiceOver/Narrator/browser-screen-reader qualification.

## 18. External links

Use the shared allowed-URI policy and explicit user action. Do not add hidden network calls, analytics, redirects, or unsupported URI schemes.

## 19. Dependencies

Before adding a package, justify:

- why existing Flutter/Dart/platform APIs are insufficient;
- maintenance status;
- license;
- privacy/network behavior;
- binary/build size;
- platform support;
- SDK/toolchain compatibility;
- supply-chain risk.

Update dependency documentation and run platform verification where the package has native implementations.

## 20. Format and analyze during development

```bash
dart format lib test tool
flutter analyze
```

Do this before creating the final commit so formatter noise does not hide the behavioral change.

## 21. Run focused tests

Example:

```bash
flutter test test/custom_game_builder_screen_test.dart
```

Then run the complete suite:

```bash
flutter test
```

A focused test is not a substitute for the complete suite before review.

## 22. Run repository gates

```bash
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
```

For Web-impacting/current candidate changes:

```bash
flutter build web --release
```

## 23. Build impacted native targets

Use [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md).

Do not claim Android/iOS/desktop support from a Dart-only unit test when native configuration or plugins changed.

## 24. Inspect your diff

```bash
git status
git diff
git diff --check
```

Look specifically for:

- secrets;
- keystores/signing files;
- generated build output;
- accidental lockfile changes;
- debug logging;
- stale TODO/FIXME;
- unrelated formatting churn;
- documentation/version contradictions.

## 25. Commit logically

Use small meaningful Conventional Commits, for example:

```text
fix: preserve custom session identity on restart
test: cover custom record isolation
docs: document custom preset trust policy
```

Do not split one inseparable code line into artificial commits solely to increase commit count. The repository benefits from many **meaningful** reviewable commits, not noise.

## 26. Rebase/update before review

Before opening a PR, ensure the branch is based on current `main` and resolve conflicts deliberately. Re-run affected tests after conflict resolution.

A green workflow from an older base is historical evidence; it does not automatically verify newly integrated source.

## 27. Pull request content

A useful PR explains:

- problem and solution;
- behavior/trust/persistence impact;
- tests performed;
- accessibility/privacy/security impact;
- platform impact;
- breaking changes/migration;
- remaining genuine manual checks.

Do not pre-check test boxes you did not actually run or observe.

## 28. Review CI

For the exact PR head verify the required maintained workflows:

- CI formatter/analyzer/tests/audits/Web;
- Dependency Review where applicable;
- Platform Builds when platform/source scope requires it.

If CI fails, inspect the first meaningful failure and fix it rather than rerunning blindly.

## 29. Stable-release evidence is separate

The repository has 13 manual release-qualification checks. They require representative real environments.

Never convert a hosted build, screenshot, unit test, or documentation review into fake manual evidence.

## 30. Documentation rule

Every meaningful behavior change should update the matching documentation and `what_changed.md`; release-facing changes should also update `CHANGELOG.md`.

Run the documentation/repository audits so links and required files remain valid.

## 31. Final pre-review checklist

- [ ] Correct layer changed.
- [ ] Regression test added/updated.
- [ ] Formatter clean.
- [ ] Analyzer clean.
- [ ] Focused tests pass.
- [ ] Complete tests pass.
- [ ] Repository/source audits pass.
- [ ] Persisted/external data remains validated and bounded.
- [ ] Reset behavior reviewed for new keys.
- [ ] Imported/custom/replay/Auto Play trust boundaries preserved.
- [ ] English/Hindi reviewed when user-facing text changed.
- [ ] Accessibility/responsive impact reviewed.
- [ ] No secrets/generated junk committed.
- [ ] Docs/changelog/continuity updated.
- [ ] Same-commit CI evidence reviewed before making release claims.

## 32. Where to go next

- Architecture: [`ARCHITECTURE.md`](ARCHITECTURE.md)
- Flow walkthrough: [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md)
- Testing: [`TESTING.md`](TESTING.md)
- Build artifacts: [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md)
- Error diagnosis: [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md)
- Custom games: [`CUSTOM_GAME_BUILDER.md`](CUSTOM_GAME_BUILDER.md)
- Maintenance: [`MAINTENANCE_POLICY.md`](MAINTENANCE_POLICY.md)
- Contribution contract: [`../CONTRIBUTING.md`](../CONTRIBUTING.md)