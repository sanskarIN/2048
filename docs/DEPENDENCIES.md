# Dependency Policy

2048 Nova keeps runtime dependencies deliberately small so the deterministic game engine stays easy to audit, test, build across platforms, and maintain offline.

## Runtime packages

### Flutter SDK

Flutter provides:

- application/widget framework;
- Material UI;
- animation;
- accessibility/semantics;
- keyboard and gesture input;
- clipboard API used by Game Backup;
- system sound/haptic platform APIs;
- platform integration;
- testing foundations.

The project does not add a separate state-management framework; `ChangeNotifier` and `InheritedNotifier` are sufficient for the current application architecture.

### shared_preferences

Used for small local project-owned values such as:

- current game snapshot;
- bounded Undo history;
- settings;
- statistics;
- achievements;
- Daily Challenge history;
- current-game unranked marker.

Why it is used:

- stored data is small and local;
- no relational query engine is needed;
- no account/cloud synchronization is required;
- it avoids adding a database solely for a puzzle game.

The application does not treat stored strings as trusted. JSON/state/configuration is validated on read, corrupt current-game data fails safely, bounded collections can salvage valid neighboring records, and project reset removes only owned keys.

### url_launcher

Used only when a player explicitly opens GitHub, LinkedIn, Buy Me a Coffee, or an email action.

Why it is used:

- external navigation is delegated to platform handlers;
- the game does not implement a custom browser/payment/email stack;
- the shared link helper validates supported secure destinations before launch;
- launch failure can offer a copy fallback rather than crashing.

## Features that add no runtime package

### Game Backup

Portable current-game backup uses:

- `dart:convert` for JSON;
- Flutter `Clipboard` / `ClipboardData` for explicit copy/paste.

No file picker, cloud-storage SDK, encryption library, account service, or network package is required for the current clipboard-based feature.

### Move Replay

Replay is built from existing current-game and Undo data using pure project code. It adds no database, media, or playback dependency.

### Hint and Auto Play Demo

The heuristic solver and isolated autoplay session use local Dart code only. They do not download a model, call a remote AI service, or add a numerical/ML framework.

### Daily Challenge

Daily Challenge uses a local UTC date-derived seed and existing deterministic engine. It does not require a server or networking package.

## Development packages

### flutter_test

Provides unit, widget, semantics, and integration-like widget-flow testing foundations used by the repository's automated suite.

### flutter_lints

Provides baseline static-analysis rules, supplemented by project-specific analyzer rules in `analysis_options.yaml`.

## Lockfile policy

2048 Nova is an application, so `pubspec.lock` is committed. This improves reproducibility across local development and CI.

A dedicated GitHub Actions workflow can resolve/commit lockfile changes, while Dependabot provides update discovery. Dependency updates still require analyzer/test/build verification.

## Dependency-review checklist

Before adding a new package:

1. Confirm the capability is not already practical with Dart, Flutter, or the target platform APIs.
2. Explain the exact feature that needs the package.
3. Check maintenance activity and supported Flutter/Dart versions.
4. Check Android/iOS/Web/Windows/macOS/Linux support when the feature is cross-platform.
5. Review the package and important transitive licenses.
6. Review whether it transmits data, creates identifiers, requires accounts, or introduces telemetry.
7. Review application/binary size and build-time impact.
8. Avoid duplicate-purpose packages.
9. Add tests around the integration boundary.
10. Run formatter, analyzer, full automated tests, Web build, and relevant native builds.
11. Update this document, privacy documentation, and release notes when appropriate.

## Dependency-removal policy

Remove dependencies that become unnecessary, unmaintained, incompatible, insecure, or replaceable with a simpler project/platform capability. Removal should also clean platform configuration and lockfile entries and be verified across configured builds.

## Licensing

2048 Nova is MIT-licensed. Third-party package/framework licenses remain their own licenses and are exposed in-app through Flutter's standard `showLicensePage` interface.

Do not copy third-party source/assets into this repository merely to avoid declaring a dependency or license obligation.

## Current intentional exclusions

The default runtime deliberately does **not** include:

- analytics SDK;
- advertising SDK;
- crash-reporting/telemetry SDK;
- authentication/account SDK;
- cloud database/storage SDK;
- multiplayer backend SDK;
- remote AI/model API SDK;
- payment SDK;
- generic HTTP client dependency for gameplay;
- separate state-management framework;
- database package.

Future work can revisit these choices only with explicit product, privacy, maintenance, and cross-platform review.
