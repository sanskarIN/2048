# Phase 31 Web/PWA Verification Record

Date: **2026-08-19**

This record covers the Web/PWA source hardening added after the Phase 31 release-qualification status reporter. It documents what is source-controlled and regression-guarded without claiming a browser installation, service-worker lifecycle, or deployed-origin qualification that has not actually been observed.

## Scope

The follow-up hardening covers:

- `web/manifest.json` install identity, scope, language/direction, categories, and icon metadata;
- `web/index.html` document language, theme/color-scheme, viewport, mobile-install hints, manifest link, touch icon, and Flutter bootstrap contract;
- `test/web_pwa_metadata_test.dart` focused source regression checks;
- semantic Web/PWA validation inside `tool/repository_audit.dart`;
- process-level repository-audit fixtures for manifest and HTML drift;
- `docs/PWA.md`, the documentation index, roadmap, and active continuity record;
- preservation of the original Phase 0–30 continuity history in `what_changed_archive_phase_00_30.md`.

## Manifest contract

The maintained source manifest declares:

```text
name: 2048 Nova
short_name: 2048 Nova
id: .
start_url: .
scope: .
display: standalone
lang: en
dir: ltr
orientation: any
prefer_related_applications: false
```

It also contains `games` and `entertainment` categories and exactly four PNG install-icon entries:

- regular 192×192;
- regular 512×512;
- maskable 192×192;
- maskable 512×512.

Relative `id`, `start_url`, and `scope` values intentionally avoid hard-coding one hosting origin or repository path into source. Real subpath deployment still requires a correctly configured Flutter base href and hosting environment.

## HTML shell contract

The maintained source shell requires:

- `<html lang="en">`;
- Flutter's `$FLUTTER_BASE_HREF` placeholder;
- project theme color;
- `light dark` color-scheme metadata;
- responsive `viewport-fit=cover` viewport metadata;
- generic mobile-Web-app capability metadata;
- Apple mobile-Web-app capability/title metadata;
- manifest and Apple touch-icon links;
- `2048 Nova` document title;
- the Flutter bootstrap script.

These declarations improve source metadata and install presentation. They do not prove that every browser or operating system will expose identical installation UI.

## Focused regression coverage

`test/web_pwa_metadata_test.dart` checks the maintained manifest and HTML source directly. It verifies the canonical manifest identity/scope/language contract, categories, colors, icon purposes/sizes, physical icon-file existence, install-related HTML metadata, Flutter base-href placeholder, responsive viewport, title, and bootstrap script.

`test/current_release_state_test.dart` separately guards that the PWA source, documentation, and repository-audit wiring remain part of the current Version 1.5 state.

## Repository audit coverage

`tool/repository_audit.dart` now protects both presence and semantics:

1. Web/PWA source files and icon assets must exist and be non-empty.
2. The manifest must parse as JSON.
3. Canonical identity/start/scope/display/language/direction/orientation/related-app values must match.
4. Categories must include `games` and `entertainment`.
5. Icons must be PNG and exactly match the maintained regular/maskable 192/512 matrix.
6. Required HTML install/source fragments must remain present.
7. The active Phase 31 continuity record and the preserved Phase 0–30 archive must both remain present.

Process-level fixture coverage explicitly verifies that manifest identity drift and HTML document-language drift fail closed.

## Source verification performed in this work pass

The GitHub repository contents were read back after the writes to verify the checked-in manifest, HTML shell, focused tests, repository-audit logic, documentation, and continuity files. The live `main` branch was also queried directly for repository-protection metadata during this pass.

No local Flutter/Dart runtime is available in the current execution environment, and the available GitHub connector has not exposed a fresh complete Actions run result for these newest commits. Therefore this record deliberately does **not** claim a new full formatter/analyzer/test/Web-build pass. The latest previously accepted full automated/native evidence remains the Phase 29 Version 1.5 baseline recorded in the maintained verification files.

## Repository-settings re-verification

The live `main` branch metadata was re-read during this Phase 31 follow-up and still reported branch protection disabled, with required status checks unenforced. The available connector still exposes no branch-protection/ruleset write operation. Issue #12 remains open and received a fresh evidence comment rather than being falsely closed through source changes.

Issue #10 also remains a deliberate Android-toolchain deferral. This PWA hardening does not alter the accepted Android AGP/Kotlin/Gradle baseline.

## Manual qualification boundary

The live Version 1.5 release-qualification manifest remains **0/13** passed. In particular, the following Web/PWA-related behavior still requires representative real-environment checking before a stable-release claim:

- deployed-origin loading;
- install availability and installed launch behavior;
- browser/service-worker update lifecycle;
- storage persistence/eviction/private-browsing behavior;
- clipboard and file handlers;
- browser/email external handlers;
- responsive/focus/keyboard/screen-reader behavior in representative browsers.

Automated source tests, repository audits, and `flutter build web --release` are useful gates, but they are not substitutes for those real-world checks.

## Maintainer verification commands

When a Flutter/Dart environment and maintained CI are available, the intended verification sequence is:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

The strict stable gate remains:

```bash
dart run tool/release_readiness.dart --stable --json
```

and must remain closed while real-world evidence is incomplete.
