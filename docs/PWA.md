# Web / Progressive Web App Guide

2048 Nova supports the Flutter Web target and includes install-oriented Web App Manifest metadata for compatible browsers. This document describes the source-controlled metadata, deployment assumptions, and qualification boundaries without treating hosted compilation as proof of installation behavior on every browser or device.

## Source files

The maintained Web/PWA entry points are:

```text
web/index.html
web/manifest.json
web/favicon.svg
web/icons/Icon-192.png
web/icons/Icon-512.png
web/icons/Icon-maskable-192.png
web/icons/Icon-maskable-512.png
```

Flutter generates the remaining release assets during `flutter build web --release`.

## Manifest contract

`web/manifest.json` declares:

- application name and short name: **2048 Nova**;
- install identity (`id`) relative to the deployed application root;
- relative `start_url` and `scope` so the source remains suitable for root or subpath deployments when the Flutter base href is configured correctly;
- standalone display mode;
- English source-document metadata (`lang: en`, `dir: ltr`);
- theme/background colors aligned with the project Web shell;
- game/entertainment categories;
- explicit regular and maskable 192×192 and 512×512 PNG icon entries;
- no preference for a separate related native application.

The application itself supports English and Hindi at runtime. The manifest language describes the manifest metadata strings; it does not override the in-app locale setting.

## HTML shell contract

`web/index.html` keeps Flutter's build-time base placeholder:

```html
<base href="$FLUTTER_BASE_HREF">
```

It also declares:

- `lang="en"` on the HTML document;
- responsive viewport behavior including `viewport-fit=cover`;
- project description and theme color;
- light/dark color-scheme capability;
- generic and Apple mobile-Web-app capability metadata;
- Apple touch icon metadata;
- the Web App Manifest link;
- the project SVG favicon;
- the Flutter bootstrap script.

## Root deployment

A normal root deployment can use the standard release command:

```bash
flutter build web --release
```

Deploy the generated `build/web/` directory as one coherent artifact. Do not deploy source `web/` directly as the finished application.

## Subpath deployment

When hosting below a path such as `/2048/`, build with an appropriate Flutter base href for the real deployment location. Keep the manifest `id`, `start_url`, and `scope` relative rather than hard-coding a repository-hosting URL in source.

The deployed server must route application navigation consistently with the chosen hosting model. Hosting configuration is external to this repository and must be validated on the actual target service.

## HTTPS and installation

Production installation behavior depends on the browser, operating system, origin, hosting configuration, and the generated Flutter Web output. A successful `flutter build web --release` proves that the Web target compiles; it does not prove that every browser will expose the same installation UI or lifecycle behavior.

Before calling a Web/PWA distribution target qualified, test the actual deployed origin on representative browsers/devices and record any required release evidence through the Version 1.5 qualification process.

## Offline-first boundary

2048 Nova is designed around local gameplay and local persistence. The Web build does not introduce an account, analytics service, advertising SDK, cloud save, or server requirement into the game model.

Browser storage, caching, eviction, private-browsing behavior, clipboard/file handlers, install state, and service-worker lifecycle are controlled partly by the browser environment. Do not represent those environment-specific behaviors as manually verified solely because automated tests or hosted Web compilation pass.

## Automated regression coverage

`test/web_pwa_metadata_test.dart` protects the maintained source metadata by checking:

- stable manifest identity/start/scope values;
- language, direction, display, categories, and colors;
- the complete regular/maskable icon matrix;
- existence and non-empty size of every manifest icon file;
- document language and mobile-install metadata in `web/index.html`;
- the manifest/touch-icon links;
- Flutter base-href, viewport, title, and bootstrap-script contracts.

These tests prevent accidental source drift. They are not a replacement for a real installed-PWA/browser qualification pass.

## Repository integrity audit

`tool/repository_audit.dart` independently protects the same source boundary at repository-maintenance time. It requires the manifest, HTML shell, favicon, all four regular/maskable icon assets, this guide, and the preserved Phase 0–30 continuity archive to exist and be non-empty.

The audit also parses the manifest and checks the canonical identity/start/scope, language/direction, display/orientation policy, categories, and exact icon matrix. It checks required install-oriented HTML fragments including the Flutter base-href placeholder, mobile/Apple metadata, manifest link, touch icon, title, and bootstrap script.

Run it directly with:

```bash
dart run tool/repository_audit.dart --json
```

This gives maintainers a lightweight deterministic integrity check in addition to the Flutter regression suite. It does not simulate browser installation or replace manual Web/PWA qualification.

## Focused verification record

[`PHASE_31_PWA_VERIFICATION.md`](PHASE_31_PWA_VERIFICATION.md) records the exact Phase 31 Web/PWA source contract, fail-closed regression coverage, repository-settings re-verification, and the boundary between checked-in source review and unobserved full CI/browser qualification.

## Release verification

The maintained automated sequence continues to include:

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

The strict stable gate remains fail-closed until the real-world qualification manifest is complete. Web/PWA metadata hardening does not change the current manual qualification count.
