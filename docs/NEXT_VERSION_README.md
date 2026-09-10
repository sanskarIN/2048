# 2048 Nova — Next-Version Index

The planned next release is **Version 2.1.0**.

This index is intentionally separate from the current Version 2.0.12 release documentation. The active package/build identity remains `2.0.12+2012` until the 2.1.0 migration is deliberately activated.

## Preparation status

```text
Current marketing version: 2.0.12
Current package/build: 2.0.12+2012
Planned next marketing version: 2.1.0
2.1.0 activation state: preparation-only
Browser extension status: design/templates prepared, not supported package
```

## Read in this order

1. [`NEXT_VERSION_2_1_0.md`](NEXT_VERSION_2_1_0.md) — release theme, scope, activation gates, and phased implementation plan.
2. [`BROWSER_EXTENSION_FOUNDATION.md`](BROWSER_EXTENSION_FOUNDATION.md) — extension architecture, least-privilege policy, CSP/storage/build/qualification design.
3. [`NEXT_VERSION_MIGRATION_CHECKLIST.md`](NEXT_VERSION_MIGRATION_CHECKLIST.md) — exact atomic migration and release-qualification checklist.
4. [`../tool/next_version_contract.json`](../tool/next_version_contract.json) — machine-readable planned/current release contract.
5. [`../extension/README.md`](../extension/README.md) — browser-extension preparation directory and activation rules.
6. [`../extension/manifests/chromium/manifest.template.json`](../extension/manifests/chromium/manifest.template.json) — permission-free Chromium Manifest V3 template.
7. [`../extension/manifests/firefox/manifest.template.json`](../extension/manifests/firefox/manifest.template.json) — Firefox Manifest V3 template with browser-specific settings kept isolated.

## What preparation means

Preparation allows the repository to establish future architecture, migration contracts, templates, tests, and documentation while preserving the current stable/source-complete release identity.

Preparation does **not** mean:

- `pubspec.yaml` has been bumped;
- 2.1.0 is a release candidate;
- browser-extension support is available to users;
- Chrome Web Store or Firefox Add-ons packages exist;
- existing 2.0.12 manual evidence applies to 2.1.0;
- browser extension permissions have been granted or requested;
- the extension has been loaded in a real browser.

## Activation sequence

The intended sequence is:

```text
finish/verify Phase 34 maintenance
        ↓
preserve 2.0.12 evidence
        ↓
verify 2.1.0 preparation/preflight
        ↓
activate 2.1.0 version identity atomically
        ↓
implement extension host/package in phases
        ↓
automated extension package audits
        ↓
real-browser qualification
        ↓
new stable-release evidence gate
```

## Scope boundary

Version 2.1.0 is currently scoped as a platform-integration/browser-extension foundation release. The six maintained Flutter application target families remain first-class:

- Android;
- iOS;
- Web/PWA;
- Windows;
- macOS;
- Linux.

The extension is planned as an additive seventh distribution surface. It must not cause an existing platform runner or build contract to be removed.

## Privacy/security baseline

The planned extension begins with:

- zero host permissions;
- zero browser permissions in the templates;
- no content scripts;
- no remote executable code;
- no browsing-history collection;
- no page-content collection;
- no telemetry requirement;
- no account requirement;
- no cloud requirement;
- no advertising requirement.

Any future expansion requires explicit review under `BROWSER_EXTENSION_FOUNDATION.md` and `NEXT_VERSION_MIGRATION_CHECKLIST.md`.

## Current release remains authoritative

For current Version 2.0.12 release status, use:

- [`README.md`](README.md) for the canonical documentation index;
- [`FINAL_2_0_12_SOURCE_AUDIT.md`](FINAL_2_0_12_SOURCE_AUDIT.md);
- [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md);
- [`../what_changed.md`](../what_changed.md);
- [`../CHANGELOG.md`](../CHANGELOG.md).

Do not rewrite those current-release contracts to 2.1.0 until the atomic activation stage.
