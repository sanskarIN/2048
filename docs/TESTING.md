# Testing Strategy

2048 Nova uses automated tests for deterministic rules, persistence integrity, controller behavior, and important UI flows. GitHub Actions is the objective source of truth for repository-wide formatter, analyzer, test, and build status.

## Unit coverage

`test/game_engine_test.dart` covers:
- Starting tile creation.
- Compression and valid-move spawning.
- Single-merge semantics and chained-merge prevention.
- Score and merge accounting.
- Invalid-move spawn prevention.
- Vertical movement.
- Game-over and target-win detection.
- Move-limit and time-limit rules.
- Deterministic persisted RNG behavior.

`test/game_state_test.dart` covers serialization, validation, and highest-tile derivation.

`test/daily_record_test.dart` covers Daily Challenge progress, completion, retained wins, and serialization.

`test/local_store_test.dart` covers save/resume, undo history, Daily Challenge persistence, scoped data clearing, and malformed-save recovery.

`test/app_controller_test.dart` covers persisted appearance/accessibility settings, serialized move requests, and complete local reset behavior.

## Widget coverage

`test/widget_smoke_test.dart` validates app startup/navigation, theme selection, and availability of the primary game modes.

## CI quality gate

The main CI workflow executes:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build web --release
```

Separate platform-build jobs compile configured native targets where the GitHub runner supports the required toolchain.

## Regression rule

When a defect is found:

1. Reproduce it.
2. Add or update a test when practical.
3. Fix the underlying cause.
4. Run the focused tests.
5. Run the broader CI quality gate.
6. Record meaningful project-level changes in `what_changed.md`.

## Manual QA

Automated tests do not replace manual interaction checks. Stable releases should additionally verify touch/swipe behavior, keyboard focus, screen readers, responsive layouts, platform external-link handlers, native splash/icon presentation, haptic/sound capability behavior, and release packaging on actual supported devices where available.
