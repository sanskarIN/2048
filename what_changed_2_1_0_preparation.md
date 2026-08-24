# 2048 Nova — Version 2.1.0 Preparation Continuity

Date: **2026-08-24**

This file records work that prepares the next release without rewriting the current Version 2.0.12 source-completion and qualification history.

## Release identities

```text
Current marketing version: 2.0.12
Current package/build version: 2.0.12+2012
Current manual qualification: 0/13 recorded passed evidence
Planned next marketing version: 2.1.0
2.1.0 package/build version: not activated yet
```

## Why the package is not bumped yet

The current Version 2.0.12 line still has an open Phase 34 maintenance PR and real-world qualification remains separate from source completion. A package-only version bump would create version drift across release tooling, qualification metadata, platform fallback values, documentation, and tests.

The 2.1.0 preparation therefore establishes the scope and migration contract first. Package activation must happen atomically after the integration base is clean.

## Version 2.1.0 theme

The planned 2.1.0 theme is:

**platform integration and browser-extension foundation**

The intended release adds a carefully bounded browser-extension distribution path while preserving Android, iOS, Web/PWA, Windows, macOS, and Linux as maintained first-class targets.

## Prepared documents

### `docs/NEXT_VERSION_2_1_0.md`

Defines:

- planned 2.1.0 release theme;
- browser-extension goals;
- extension-safe Flutter Web/CSP investigation requirements;
- six-target non-regression requirement;
- atomic version migration rule;
- least-privilege permission policy;
- privacy/trust requirements;
- preparation/activation gates;
- implementation phases;
- explicit preparation-stage non-goals.

### `docs/BROWSER_EXTENSION_FOUNDATION.md`

Defines:

- browser-independent domain boundary;
- Manifest V3 Chromium baseline;
- Firefox-specific packaging boundary;
- no-permission default;
- extension storage adapter boundary;
- Flutter Web extension-CSP investigation;
- small initial extension UI scope;
- build/package/CI goals;
- real-browser manual qualification requirements;
- security and cross-platform non-regression rules.

### `docs/NEXT_VERSION_MIGRATION_CHECKLIST.md`

Defines the atomic migration checklist covering:

- clean integration base;
- preservation of Version 2.0.12 evidence;
- all version-coupled source/platform/tool/documentation surfaces;
- extension activation gates;
- permission escalation review;
- new 2.1.0 qualification evidence;
- extension package auditing;
- documentation activation;
- stable 2.1.0 promotion.

### `docs/NEXT_VERSION_README.md`

Provides the dedicated next-version reading/index path while keeping the current Version 2.0.12 documentation canonical until activation.

## Machine-readable preparation contract

`tool/next_version_contract.json` records:

```text
schemaVersion: 1
status: planned
current release: 2.0.12 / 2.0.12+2012
next marketing release: 2.1.0
next activation state: preparation-only
Chromium manifest model: Manifest V3
Firefox WebExtensions preparation: enabled
host permissions by default: none
browser permissions by default: none
remote executable code: disallowed
content scripts by default: false
browsing/page data collection: false
telemetry/cloud/accounts/advertising requirements: false
```

The contract also lists the authoritative version-migration paths and activation gates.

## Browser-extension preparation directory

The following preparation-only files now exist:

```text
extension/README.md
extension/manifests/chromium/manifest.template.json
extension/manifests/firefox/manifest.template.json
```

They are deliberately templates, not active `manifest.json` release packages.

Both templates:

- use Manifest V3;
- use planned version `2.1.0`;
- define the smallest action/popup host surface;
- request no host permissions;
- request no browser permissions;
- define no content scripts.

The Firefox template isolates `browser_specific_settings` and declares no data collection in its preparation metadata.

## Preparation commits

```text
e7504a4b  docs: define Version 2.1.0 preparation scope
2399de17  docs: define browser extension foundation
b1cdc71b  chore: add machine-readable 2.1.0 contract
f21ae1d2  chore: add browser extension preparation skeleton
629c3af7  chore: add Chromium MV3 manifest template
f3e9c6fa  chore: add Firefox MV3 manifest template
0ff997be  docs: add atomic 2.1.0 migration checklist
2775c50d  docs: index Version 2.1.0 preparation
```

This continuity file is committed separately so the actual preparation artifacts and their historical record remain independently reviewable.

## Phase 34 dependency

The 2.1.0 preparation branch was stacked from the Phase 34 maintenance branch before Phase 34 integration was complete.

Phase 34 currently addresses:

- all-platform qualification package/checksum enforcement;
- stable platform-audit JSON output;
- shared fail-closed audit root arguments;
- retained machine-readable CI audit reports;
- stronger formatting diagnostics;
- related regression and documentation protection.

The 2.1.0 branch must be synchronized onto the final integrated Phase 34 head before its own integration.

## Current verification boundary

No supported browser-extension package is claimed yet.

No Chrome Web Store, Firefox Add-ons, Safari extension, real-browser extension load, extension update/restart, extension accessibility, extension offline behavior, or extension store-review evidence is being claimed by these preparation files.

The Version 2.0.12 manual qualification boundary remains 0/13 until genuine evidence is recorded.

## Next implementation sequence

After Phase 34 is formatter/analyzer/test/audit/build clean and integrated:

1. synchronize/rebase the 2.1.0 preparation branch onto that exact base;
2. add a fail-closed next-version preflight for `tool/next_version_contract.json` and extension templates;
3. regression-test the preparation contract;
4. decide and qualify the extension-safe Flutter/Web staging approach under Manifest V3 CSP;
5. add deterministic extension package/audit scripts;
6. activate the 2.1.0 package identity atomically only when the migration gates are ready;
7. begin a fresh qualification record for the changed 2.1.0 scope;
8. qualify real Chromium/Firefox extension behavior before any support/publication claim.
