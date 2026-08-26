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
