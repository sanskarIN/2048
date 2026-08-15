# 2048 Nova Documentation

This directory is the user, technical, development, platform, and release documentation set for 2048 Nova. The application is a Flutter/Dart, offline-first 2048 implementation with deterministic game rules, validated local persistence, multiple modes, trusted per-mode records, English/Hindi localization, accessibility controls, read-only Replay, an isolated Heuristic/Expectimax Auto Play Demo with deterministic solver benchmarks, portable current-game backup/restore, and offline shareable seeded challenge codes.

## Start here

| Document | Purpose |
| --- | --- |
| [`../README.md`](../README.md) | Project overview, features, setup, controls, build commands, links, and support. |
| [`USER_GUIDE.md`](USER_GUIDE.md) | Complete player guide for rules, controls, modes, Undo, Hint, Replay, Auto Play, Backup, Challenge Codes, language/settings, and data controls. |
| [`FAQ.md`](FAQ.md) | Common user/developer questions about rules, modes, saves, Replay, Auto Play, Backup, Challenge Codes, language, privacy, accessibility, platforms, and release status. |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Layer boundaries, state flow, persistence responsibilities, trust boundaries, and feature architecture. |
| [`GAME_ENGINE.md`](GAME_ENGINE.md) | Exact move/merge/spawn rules, deterministic RNG, terminal-state behavior, and invariants. |
| [`GAME_MODES.md`](GAME_MODES.md) | All supported game modes, board sizes, targets, timers, move limits, and Daily Challenge behavior. |
| [`MODE_RECORDS.md`](MODE_RECORDS.md) | Trusted local per-mode best score/highest-tile records, migration, reset behavior, and imported-backup isolation. |
| [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md) | Shareable seeded challenge format, deterministic behavior, validation, checksum, and trust model. |
| [`LOCALIZATION.md`](LOCALIZATION.md) | English/Hindi locale architecture, persisted language selection, fallback rules, contributor guidance, privacy, and accessibility boundaries. |
| [`DATA_STORAGE.md`](DATA_STORAGE.md) | Local storage keys, save schemas, bounded collections, corruption recovery, and reset behavior. |
| [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) | Portable current-game backup format, clipboard workflow, strict validation, and unranked-import policy. |
| [`HINT_SOLVER.md`](HINT_SOLVER.md) | Deterministic heuristic Hint plus isolated Heuristic/Expectimax Auto Play behavior and limitations. |
| [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md) | Bounded expectimax design, node limits, sandbox trust boundary, deterministic benchmark library, and CLI harness. |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Implemented accessibility features and remaining manual assistive-technology checks, including localized semantics. |
| [`PRIVACY.md`](PRIVACY.md) | Offline-first data behavior, language/localization, clipboard, external links, local storage, Replay, Auto Play, Backup, and Challenge Code privacy. |
| [`DEVELOPMENT.md`](DEVELOPMENT.md) | Development environment, repository layout, localization practices, local workflow, testing, and contribution practices. |
| [`PLATFORMS.md`](PLATFORMS.md) | Android/iOS/Web/Windows/macOS/Linux setup, build commands, hosted verification, locale behavior, and signing/distribution boundaries. |
| [`CI_CD.md`](CI_CD.md) | Permanent GitHub Actions workflows, quality gates, native build matrix, and automation boundaries. |
| [`TESTING.md`](TESTING.md) | Automated test strategy, regression areas, and current evidence. |
| [`VERIFICATION.md`](VERIFICATION.md) | Compact current automated verification record. |
| [`PHASE_17_VERIFICATION.md`](PHASE_17_VERIFICATION.md) | Focused Phase 17 trusted per-mode-record acceptance history and final 144-test Web/WASM gate. |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Automated and manual qualification checklist before stable release. |
| [`BRANDING.md`](BRANDING.md) | Logo/icon/splash sources and generated platform assets. |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Runtime/development dependency rationale and licensing notes. |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Common setup, build, save, input, backup, challenge-code, localization, and platform troubleshooting. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Contribution architecture, localization, quality, testing, documentation, and PR requirements. |
| [`../SECURITY.md`](../SECURITY.md) | Security-reporting and current trust boundaries. |
| [`../SUPPORT.md`](../SUPPORT.md) | User/developer support channels and report information. |
| [`../ROADMAP.md`](../ROADMAP.md) | Completed and optional future work. |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Release-facing history. |
| [`../what_changed.md`](../what_changed.md) | Detailed chronological implementation and verification log. |

## Documentation principles

The documentation follows behavior implemented in the repository rather than describing aspirational features as complete. Historical verification entries are kept as historical evidence; newer entries supersede older test counts for the current source state.

Automated build success does not imply that every physical device, assistive-technology combination, app-store signing configuration, localized layout, or long-running user session has been manually validated. Those boundaries are stated explicitly in the release and verification documents.

A feature should not be documented as ranked/trusted when its source policy makes it unranked, a configured platform should not be described as release-qualified solely because its runner files exist, and a locale should not be described as manually qualified solely because automated localization tests pass.

## Source-of-truth boundaries

- **Game rules:** `lib/domain/game_engine.dart`, `lib/domain/game_state.dart`, and `lib/domain/game_types.dart`.
- **Localization:** `lib/core/localization/nova_localizations.dart` and `lib/core/localization/hindi_translations.dart`.
- **Challenge-code codec:** `lib/domain/challenge_code.dart`.
- **Portable backup codec:** `lib/domain/game_backup.dart`.
- **Replay timeline:** `lib/domain/replay_timeline.dart`.
- **Auto Play sandbox:** `lib/domain/autoplay_session.dart`.
- **Advanced solver:** `lib/domain/expectimax_solver.dart`.
- **Solver benchmark library:** `lib/domain/solver_benchmark.dart`.
- **Local persistence:** `lib/data/local_store.dart`.
- **Player session/ranking/settings orchestration:** `lib/app/state/app_controller.dart`.
- **Per-mode record presentation:** `lib/features/statistics/statistics_screen.dart`.
- **Application routes/localization delegates:** `lib/app/nova_app.dart`.
- **Current package/version:** `pubspec.yaml`.
- **Automated quality gates:** `.github/workflows/`.

When a document and source code disagree, review current source/tests and correct the documentation in the same change. Do not silently change implementation facts in documentation to match an intended-but-unimplemented design.

## Verification hierarchy

For current release confidence, consult in this order:

1. [`VERIFICATION.md`](VERIFICATION.md) for the compact latest confirmed automated state.
2. [`TESTING.md`](TESTING.md) for coverage intent and regression areas.
3. [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) for automated plus remaining manual qualification.
4. [`../what_changed.md`](../what_changed.md) for the complete chronological record, including intermediate failures and fixes.

## Project identity

- Project: **2048 Nova**
- Repository: https://github.com/sanskarIN/2048
- Creator branding: **Made by the Sanskar**
- License: MIT
- Business: `sanskarin@outlook.in`, `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- Buy Me a Coffee: https://buymeacoffee.com/sanskarIN
