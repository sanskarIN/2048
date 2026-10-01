# Browser Extension Source

This directory contains only browser-extension wrapper source. It does **not** duplicate the 2048 game implementation.

The extension packages a normal Flutter web release under `app/` and opens that build inside a small toolbar popup shell.

## Files

- `manifest.chromium.template.json` — Manifest V3 template for Chrome, Edge, and other Chromium-family browsers.
- `manifest.firefox.template.json` — Manifest V3 template for Firefox, including Gecko signing/privacy metadata.
- `popup.html` — CSP-safe extension popup shell with no inline JavaScript.
- `popup.css` — popup sizing/layout only.

Generated extension packages are written under `build/browser-extension/` and are intentionally not tracked.

## Build

```bash
flutter build web --release --base-href /app/
dart run tool/package_browser_extension.dart --browser=all
```

The packager reads the marketing version from `pubspec.yaml`, replaces `__VERSION__` in the selected manifest template, copies the Flutter web build under `app/`, and writes installable unpacked extension directories.

Run the readiness audit with:

```bash
dart run tool/browser_extension_audit.dart --json
```

See `docs/BROWSER_EXTENSION.md` for browser loading, packaging, release, privacy, and store-preparation details.
# 2048 Nova Browser Extension Preparation

This directory is reserved for the planned Version 2.1.0 browser-extension distribution surface.

**Current status:** preparation/template only. The repository does not yet claim a supported or publishable browser extension.

The existing application targets remain:

- Android;
- iOS;
- Web/PWA;
- Windows;
- macOS;
- Linux.

The extension will be additive and must reuse the shared deterministic game architecture rather than duplicating game rules in browser-specific code.

## Preparation layout

```text
extension/
  README.md
  manifests/
    chromium/
      manifest.template.json
    firefox/
      manifest.template.json
```

Future activation may add a staged/generated UI directory, package scripts, permission audits, and deterministic ZIP/checksum output.

## Template rules

The files under `manifests/` are intentionally named `manifest.template.json` so browsers, CI, and maintainers do not mistake them for completed packages.

The templates currently enforce these design choices:

- Manifest V3;
- Version 2.1.0 planning identity;
- toolbar action/popup as the smallest initial UI surface;
- no host permissions;
- no browser permissions;
- no content scripts;
- no remotely hosted executable code declaration;
- Firefox-specific settings isolated to the Firefox template.

A real package must be generated into a build/output directory rather than editing a template into an undocumented state.

## Why no permissions are present

A standalone 2048 game should be able to render its own packaged UI without reading arbitrary pages, tabs, history, bookmarks, or page content.

Any future permission addition requires the review process defined in [`../docs/BROWSER_EXTENSION_FOUNDATION.md`](../docs/BROWSER_EXTENSION_FOUNDATION.md).

## Before activation

Do not rename these templates to active `manifest.json` files until all of the following exist:

1. a documented extension UI build/staging command;
2. extension-CSP compatibility verification for generated Flutter/Web output;
3. manifest validation;
4. permission allowlist validation;
5. packaged-file allowlist/inventory validation;
6. no-remote-code validation;
7. archive/checksum generation;
8. representative Chromium manual-load evidence;
9. representative Firefox manual-load evidence;
10. localization/accessibility/save-resume qualification.

## Shared-code boundary

Browser APIs must stay outside the deterministic domain layer.

Do not import extension APIs into:

```text
lib/domain/
```

If extension storage or browser events are needed later, introduce narrow adapters at the application/host boundary and regression-test them separately.

## Related documents

- [`../docs/NEXT_VERSION_2_1_0.md`](../docs/NEXT_VERSION_2_1_0.md)
- [`../docs/BROWSER_EXTENSION_FOUNDATION.md`](../docs/BROWSER_EXTENSION_FOUNDATION.md)
- [`../tool/next_version_contract.json`](../tool/next_version_contract.json)
