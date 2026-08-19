# Dependency Policy

2048 Nova keeps runtime dependencies deliberately small so the deterministic game engine stays easy to audit, test, build across platforms, and maintain offline.

## Version 2.0.12 dependency freeze

Version 2.0.12 uses a compatibility-first dependency freeze. A newer package release is not automatically adopted during final source freeze unless it fixes a known project defect, security issue, or compatibility requirement and can be requalified across affected targets.

Point-in-time review on **2026-08-19**:

- `cupertino_icons 1.0.9` — project pin retained.
- `shared_preferences ^2.5.5` — current project line retained.
- `url_launcher ^6.3.2` — current project line retained.
- `qr_flutter 4.1.0` — project pin retained.
- `file_picker 11.0.2` — project pin retained; `11.0.3` is a newer stable patch, but the patch is not required to fix a known 2.0.12 product defect and is therefore intentionally deferred until a normal maintenance qualification cycle.

Dependency freshness after source completion is governed by `MAINTENANCE_POLICY.md`; it is not an unfinished Version 2.0.12 feature backlog.

## Runtime packages

### Flutter SDK

Flutter provides:

- application/widget framework;
- Material UI;
- animation;
- accessibility/semantics;
- keyboard and gesture input;
- clipboard API used by Game Backup and Challenge Codes;
- system sound/haptic platform APIs;
- platform integration;
- testing foundations.

The project does not add a separate state-management framework; `ChangeNotifier` and `InheritedNotifier` are sufficient for the current application architecture.

### cupertino_icons

Pinned at **1.0.9**. The package supplies the Cupertino icon font referenced by Flutter/Cupertino icon data. The dependency became explicit after the Web compiler correctly reported that Cupertino icon data was referenced while the font asset was absent.

The maintained 2.0.12 source line declares Dart `>=3.9.0 <4.0.0` and Flutter `>=3.35.0`. `cupertino_icons` adds no networking, analytics, account, persistence, or platform-permission behavior.

The permanent Web gate fails if Flutter again emits `Expected to find fonts for`, and repository-integrity tests verify the declaration and resolved lockfile entry remain synchronized.

### shared_preferences

Declared at **^2.5.5** and used for small local project-owned values such as:

- current game snapshot;
- bounded Undo history;
- settings;
- statistics;
- achievements;
- Daily Challenge history;
- current-game unranked marker;
- bounded full-replay capture metadata.

Why it is used:

- stored data is small and local;
- no relational query engine is needed;
- no account/cloud synchronization is required;
- it avoids adding a database solely for a puzzle game.

The application does not treat stored strings as trusted. JSON/state/configuration is validated on read, corrupt current-game data fails safely, bounded collections can salvage valid neighboring records, and project reset removes only owned keys.

Challenge Codes deliberately add no SharedPreferences key; only the resulting started game uses the existing persistence model.

The package also offers newer async/cache-oriented APIs. The current project implementation remains on its already-tested persistence abstraction for 2.0.12 rather than performing a late storage rewrite. A future API migration is maintenance work and must preserve save-schema, ordering, corruption-repair, lifecycle, and regression-test behavior.

### url_launcher

Declared at **^6.3.2** and used only when a player explicitly opens GitHub, LinkedIn, Gumroad, Buy Me a Coffee, bug-report, or email actions.

Why it is used:

- external navigation is delegated to platform handlers;
- the game does not implement a custom browser/payment/email stack;
- the shared link helper validates supported secure destinations before launch;
- launch failure can offer a copy fallback rather than crashing.

No external destination is contacted during normal gameplay without user action.

### file_picker

Pinned at **11.0.2**. It is used only by `SystemGameBackupFilePort` to open explicit user-selected save/open flows for Game Backup on the configured Flutter targets. The package does not own the backup schema, JSON validation, ranking policy, persistence, or networking.

The integration is wrapped behind the project-owned `GameBackupFilePort` interface so widget tests can inject a fake and domain code remains plugin-independent. File input is byte-bounded before strict UTF-8 decoding, then passed through the existing `GameBackup` validator.

Why it is used:

- Flutter core does not expose one uniform cross-platform Save/Open document API for all configured targets;
- the project needs Android/iOS/Web/Windows/macOS/Linux user-selected file transport;
- it preserves explicit chooser interaction rather than adding broad filesystem scanning;
- the exact pin in `pubspec.yaml`/`pubspec.lock` preserves the qualified release-candidate dependency surface.

A newer stable `11.0.3` patch was published shortly before the final 2.0.12 audit. Its Android change removes an Apache Tika dependency from `saveFile()` MIME detection. Because 2.0.12 has no known defect requiring that patch and a dependency change would require regenerated lock/plugin validation plus affected native builds, the project intentionally does not perform a last-minute patch upgrade solely for freshness.

It is not an analytics, cloud-storage, account, or networking dependency.

### qr_flutter

Pinned at **4.1.0**. It is used only to render the already-generated Challenge Code string as a local QR image. The project passes the exact `NOVA1...` text into the renderer; `qr_flutter` does not own Challenge Code encoding, checksum validation, game configuration parsing, trust policy, persistence, or networking.

The resolved lockfile also records the package's QR-encoding dependency. 2048 Nova does **not** add a QR scanner/camera package.

Why it is used:

- Flutter core does not include a QR encoder/renderer;
- local rendering avoids a network QR-generation service;
- the wrapper can enforce fixed scan contrast, responsive bounds, semantics, and a render-error fallback;
- rendering remains presentation-only and leaves the domain protocol unchanged.

It does not request camera permission, create an account, upload code contents, add analytics, or establish authenticity.

## Features that add no additional runtime package

### Challenge Code codec

Offline shareable seeded Challenge Code **encoding and validation** use:

- `dart:convert` for JSON, UTF-8, and Base64URL;
- project-owned FNV-1a checksum logic;
- Flutter clipboard APIs through the existing `TextClipboard` abstraction;
- the existing `GameConfig` strict parser and deterministic game engine.

`qr_flutter` exists only in the presentation layer described above. No networking package, account SDK, cloud service, cryptography package, database, sharing SDK, or in-app QR scanner is required. The checksum remains a corruption detector, not a cryptographic signature.

### Game Backup

Portable current-game backup uses:

- `dart:convert` for JSON/UTF-8;
- Flutter `Clipboard` / `ClipboardData` through `TextClipboard` for explicit copy/paste;
- the project-owned `GameBackupFilePort` wrapper around pinned `file_picker 11.0.2` for explicit user-selected save/open transport.

No cloud-storage SDK, encryption library, account service, or network package is required. The file dependency transports bytes only; project code owns all validation and the unranked trust policy.

### Move Replay and Full Replay Archives

Move Replay is built from existing current-game/Undo data. Full Replay Archives use repository-owned deterministic protocol/capture/playback code plus the existing explicit clipboard boundary. Neither feature adds a database, media, streaming, or network dependency.

### Hint and Auto Play Demo

The heuristic solver, bounded Expectimax search, deterministic benchmark, and isolated autoplay session use local Dart code only. They do not download a model, call a remote AI service, or add a numerical/ML framework.

### Daily Challenge

Daily Challenge uses a local UTC date-derived seed and the existing deterministic engine. It does not require a server or networking package.

## Development packages

### flutter_test

Provides unit, widget, semantics, and process/integration-like testing foundations used by the automated suite, including engine, persistence, replay, backup, Challenge Code, localization, release tooling, repository audit, Web/PWA metadata, workflow, and current-release-state regressions.

### flutter_lints

Declared at **^6.0.0**. It provides the Flutter static-analysis baseline, supplemented by project-specific analyzer rules in `analysis_options.yaml`. The lint set must pass with zero analyzer issues before dependency changes are accepted.

## Lockfile policy

2048 Nova is an application, so `pubspec.lock` is committed for reproducible builds.

A dedicated GitHub Actions workflow resolves/commits lockfile changes when dependency metadata changes and can also be manually dispatched. Permanent CI independently fails when `flutter pub get` would change the committed lockfile. Dependabot monitors Pub, Android Gradle, and GitHub Actions, while pull-request Dependency Review rejects newly introduced high-severity vulnerable dependency changes. Dependency updates still require analyzer/test/build verification.

## Dependency-review checklist

Before adding or updating a package:

1. Confirm the capability or fix is not already practical with Dart, Flutter, or target platform APIs.
2. Explain the concrete reason for the dependency change.
3. Check maintenance activity and supported Flutter/Dart versions.
4. Check Android/iOS/Web/Windows/macOS/Linux support when the integration is cross-platform.
5. Review package and important transitive licenses.
6. Review whether it transmits data, creates identifiers, requires accounts, or introduces telemetry.
7. Review application/binary-size and build-time impact.
8. Avoid duplicate-purpose packages.
9. Add or update tests around the integration boundary.
10. Run formatter, analyzer, full tests, repository audit, release gate, Web build, and affected native builds.
11. Update privacy/security/release documentation when behavior or trust boundaries change.

Challenge Codes are an example of preferring existing language/framework capabilities when they are sufficient and auditable.

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
- database package;
- camera/QR scanning package.

A future release may revisit one of these only through an explicit new product scope with privacy, security, accessibility, testing, maintenance, and cross-platform review. They are not unfinished Version 2.0.12 work.

## Localization dependency

`flutter_localizations` comes from the **Flutter SDK** so Material, Widgets, and Cupertino framework controls follow English/Hindi locale selection correctly. It is not a third-party analytics, translation, networking, or cloud dependency. Flutter's SDK localization package resolves `intl` transitively in `pubspec.lock`.

Project-specific English/Hindi strings remain in repository source under `lib/core/localization/`; no remote translation package or service is used.
