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
