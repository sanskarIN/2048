# 2048 Nova Documentation

This directory is the user, technical, development, platform, and release documentation set for 2048 Nova. The application is a Flutter/Dart, offline-first 2048 implementation with deterministic game rules, validated local persistence, multiple modes, accessibility controls, read-only Replay, an isolated heuristic Auto Play Demo, and portable current-game backup/restore.

## Start here

| Document | Purpose |
| --- | --- |
| [`../README.md`](../README.md) | Project overview, features, setup, controls, build commands, links, and support. |
| [`USER_GUIDE.md`](USER_GUIDE.md) | Complete player guide for rules, controls, modes, Undo, Hint, Replay, Auto Play, Backup, settings, and data controls. |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Layer boundaries, state flow, persistence responsibilities, trust boundaries, and feature architecture. |
| [`GAME_ENGINE.md`](GAME_ENGINE.md) | Exact move/merge/spawn rules, deterministic RNG, terminal-state behavior, and invariants. |
| [`GAME_MODES.md`](GAME_MODES.md) | All supported game modes, board sizes, targets, timers, move limits, and Daily Challenge behavior. |
| [`DATA_STORAGE.md`](DATA_STORAGE.md) | Local storage keys, save schemas, bounded collections, corruption recovery, and reset behavior. |
| [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) | Portable current-game backup format, clipboard workflow, strict validation, and unranked-import policy. |
| [`HINT_SOLVER.md`](HINT_SOLVER.md) | Deterministic heuristic Hint and Auto Play Demo behavior and limitations. |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Implemented accessibility features and remaining manual assistive-technology checks. |
| [`PRIVACY.md`](PRIVACY.md) | Offline-first data behavior, clipboard, external links, local storage, Replay, Auto Play, and backup privacy. |
| [`DEVELOPMENT.md`](DEVELOPMENT.md) | Development environment, repository layout, local workflow, testing, and contribution practices. |
| [`PLATFORMS.md`](PLATFORMS.md) | Android/iOS/Web/Windows/macOS/Linux setup, build commands, hosted verification, and signing/distribution boundaries. |
| [`CI_CD.md`](CI_CD.md) | Permanent GitHub Actions workflows, quality gates, native build matrix, and automation boundaries. |
| [`TESTING.md`](TESTING.md) | Automated test strategy, regression areas, and current evidence. |
| [`VERIFICATION.md`](VERIFICATION.md) | Compact current automated verification record. |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Automated and manual qualification checklist before stable release. |
| [`BRANDING.md`](BRANDING.md) | Logo/icon/splash sources and generated platform assets. |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Runtime/development dependency rationale and licensing notes. |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Common setup, build, save, input, backup, and platform troubleshooting. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Contribution architecture, quality, testing, documentation, and PR requirements. |
| [`../SECURITY.md`](../SECURITY.md) | Security-reporting and current trust boundaries. |
| [`../SUPPORT.md`](../SUPPORT.md) | User/developer support channels and report information. |
| [`../ROADMAP.md`](../ROADMAP.md) | Completed and optional future work. |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Release-facing history. |
| [`../what_changed.md`](../what_changed.md) | Detailed chronological implementation and verification log. |

## Documentation principles

The documentation follows behavior implemented in the repository rather than describing aspirational features as complete. Historical verification entries are kept as historical evidence; newer entries supersede older test counts for the current source state.

Automated build success does not imply that every physical device, assistive-technology combination, app-store signing configuration, or long-running user session has been manually validated. Those boundaries are stated explicitly in the release and verification documents.

A feature should not be documented as ranked/trusted when its source policy makes it unranked, and a configured platform should not be described as release-qualified solely because its runner files exist.

## Source-of-truth boundaries

- **Game rules:** `lib/domain/game_engine.dart`, `lib/domain/game_state.dart`, and `lib/domain/game_types.dart`.
- **Portable backup codec:** `lib/domain/game_backup.dart`.
- **Replay timeline:** `lib/domain/replay_timeline.dart`.
- **Auto Play sandbox:** `lib/domain/autoplay_session.dart`.
- **Local persistence:** `lib/data/local_store.dart`.
- **Player session/ranking orchestration:** `lib/app/state/app_controller.dart`.
- **Application routes:** `lib/app/nova_app.dart`.
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
