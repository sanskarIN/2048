# Browser Extension Preparation

2048 Nova's browser extension is prepared as a **next-release target**. The current Version 2.0.12 six-platform support contract remains unchanged until an extension release is explicitly qualified and versioned.

The extension reuses the Flutter web application instead of maintaining a second game implementation. This keeps gameplay, accessibility behavior, localization, persistence logic, settings, and future fixes on one Dart/Flutter code path.

## Target browsers

The source prepares two Manifest V3 packages:

- **Chromium package** — Chrome, Microsoft Edge, and compatible Chromium-family browsers.
- **Firefox package** — Firefox desktop and a Gecko configuration prepared for Firefox Android availability.

Chromium and Firefox use separate manifest templates because Firefox-specific signing/privacy keys must not be placed in the Chromium manifest.

## Architecture

Generated package layout:

```text
build/browser-extension/<browser>/
├── manifest.json
├── popup.html
├── popup.css
└── app/
    ├── index.html
    ├── flutter_bootstrap.js
    ├── manifest.json        # Flutter PWA manifest; separate from extension manifest
    ├── assets/
    ├── icons/
    └── ...
```

The extension's root `manifest.json` is generated from `extension/manifest.<browser>.template.json`. The Flutter PWA manifest remains under `app/`, so the two different manifest formats never collide.

`popup.html` contains no inline JavaScript. It hosts `app/index.html` in a same-extension-origin iframe sized for a toolbar popup.

## Why the Flutter build uses `/app/`

The packaged Flutter application lives below the extension root. Build it with:

```bash
flutter build web --release --base-href /app/
```

The packaging tool refuses a web build whose generated `index.html` does not contain `/app/` as the base href. This prevents broken absolute asset paths inside `chrome-extension://` or `moz-extension://` URLs.

## Content Security Policy

Manifest V3 extension pages cannot use arbitrary remote code or `unsafe-eval`. Flutter web can use WebAssembly depending on its renderer/toolchain, so the templates use the constrained extension-page policy:

```text
script-src 'self' 'wasm-unsafe-eval'; object-src 'self';
```

All executable code remains packaged with the extension. No host permissions are requested.

## Privacy and permissions

The prepared extension requests:

- no `permissions` array;
- no `host_permissions`;
- no background browsing access;
- no content scripts;
- no page injection;
- no browsing-history, tab, cookie, location, microphone, camera, or filesystem privileges.

The game stores its own local preferences/state within the extension origin. External HTTPS or mail links are opened only after explicit user actions through the existing Flutter UI.

The Firefox manifest declares `data_collection_permissions.required = ["none"]` for the prepared no-collection model.

If a future extension feature needs any new permission or data collection, treat that as a security/privacy change: update the manifest templates, privacy docs, browser store declarations, audit tool, tests, and release notes together.

## Build both extension directories

From the repository root:

```bash
flutter pub get
flutter build web --release --base-href /app/
dart run tool/package_browser_extension.dart --browser=all
```

Outputs:

```text
build/browser-extension/chromium/
build/browser-extension/firefox/
```

The generated extension manifest version comes from the marketing portion of `pubspec.yaml`; for example, `2.0.12+2012` becomes extension version `2.0.12`. This avoids maintaining a second version number by hand.

## Build one browser only

```bash
dart run tool/package_browser_extension.dart --browser=chromium
```

or:

```bash
dart run tool/package_browser_extension.dart --browser=firefox
```

Optional paths:

```bash
dart run tool/package_browser_extension.dart \
  --browser=all \
  --build-dir=build/web \
  --output-dir=build/browser-extension
```

## Readiness audit

Run:

```bash
dart run tool/browser_extension_audit.dart --json
```

The audit checks:

- both Manifest V3 templates;
- the version placeholder;
- permission-free manifest policy;
- WebAssembly-compatible CSP;
- Chromium/Firefox manifest separation;
- Firefox Gecko ID and no-data-collection declaration;
- popup shell source;
- packager source;
- extension CI packaging workflow;
- extension documentation and regression test presence.

## Chromium local loading

After generating the Chromium directory, use the browser's extension-management developer mode and load the **unpacked** directory:

```text
build/browser-extension/chromium/
```

Check at minimum:

- toolbar action opens;
- game renders at popup size;
- swipe/pointer and keyboard input work;
- new game, undo/settings, and other controls remain reachable;
- persistence survives closing/reopening the popup;
- dark/light theme behavior remains readable;
- external links require explicit interaction and open correctly;
- browser console contains no CSP, asset, or WebAssembly errors.

## Firefox local loading

Generate the Firefox directory and load it as a temporary extension during development. Use:

```text
build/browser-extension/firefox/manifest.json
```

Repeat the same gameplay, persistence, accessibility, CSP, and console checks as Chromium.

The Gecko extension ID in source is intended to make extension-origin persistence stable for signed Firefox builds. Change it only as a deliberate release identity migration.

## CI packaging

`.github/workflows/browser-extension.yml` performs extension qualification without changing the current stable platform matrix. It:

1. installs the pinned Flutter toolchain;
2. resolves dependencies and checks the lockfile;
3. runs the browser-extension audit;
4. builds Flutter web with `/app/` as the base href;
5. packages Chromium and Firefox directories;
6. validates generated manifests and required files;
7. creates browser-specific ZIP archives and SHA-256 checksums;
8. uploads qualification artifacts.

## Store-release gates for the next version

Preparation is not store publication. Before the extension becomes a stable supported target, complete all of the following:

1. bump `pubspec.yaml` to the intended next release version;
2. run the complete Flutter test/analyzer/audit suite;
3. run browser-extension CI successfully on that exact release commit;
4. manually load/test the generated Chromium and Firefox packages;
5. verify popup behavior at browser zoom and OS text-scaling settings;
6. verify persistence across browser restarts and extension updates;
7. prepare final store artwork/icons/screenshots in each store's required sizes;
8. verify store privacy/data-use declarations match the permission-free implementation;
9. verify extension name, description, support links, license, and version metadata;
10. submit only the generated package from the qualified release commit;
11. record real store-review/signing evidence in the release qualification record;
12. only then add Browser Extension to the stable supported-platform contract.

## Current status

**Prepared, automated, not yet declared stable.**

This distinction is intentional. Source code, manifests, packaging, CI, and documentation can be prepared in advance, but actual Chrome/Edge/Firefox behavior and store acceptance require real browser/store evidence and must not be invented.
