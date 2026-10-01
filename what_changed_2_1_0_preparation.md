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

The contract also lists the authoritative version-migration paths, its own preparation files, and activation gates.

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

## Fail-closed preparation tooling

`tool/next_version_preflight.py` is a standard-library-only preflight that protects preparation before the 2.1.0 package is activated.

It checks:

- current Version 2.0.12 package/marketing identity is still intact;
- the contract remains schema version 1 and `planned`;
- planned release remains 2.1.0 with `packageVersion: null` and `preparation-only` activation;
- every declared migration/preparation path exists;
- Chromium and Firefox templates remain Manifest V3;
- both templates remain permission-free and content-script-free;
- Firefox keeps its non-release ID placeholder and no-data-collection declaration;
- remote executable code remains forbidden by the machine contract;
- browsing/page-content collection, telemetry, cloud, accounts, and advertising remain disabled/not required;
- all six existing Flutter targets remain preserved.

`test/next_version_preflight_test.py` protects:

- clean repository preparation success;
- fail-closed broad host-permission escalation;
- fail-closed premature package activation;
- fail-closed Firefox data-collection drift.

The dedicated `.github/workflows/next-version-preflight.yml` runs the preflight/regressions, validates both manifest templates as JSON, and retains `next-version-preflight.json` for 14 days as `nova-2048-next-version-preflight`.

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
2612b943  tool: add fail-closed 2.1.0 preparation preflight
b54e0e82  chore: self-protect 2.1.0 preparation inventory
0d428d0c  test: cover fail-closed 2.1.0 preflight
dbaa83ae  ci: add Version 2.1.0 preparation preflight
```

This continuity update is committed separately so the actual preparation artifacts and their historical record remain independently reviewable.

## Pull-request structure

The preparation work is isolated in draft PR **#32**, `docs: prepare Version 2.1.0 extension foundation`, targeting the Phase 34 maintenance branch.

It intentionally remains stacked/draft while PR #28 is unresolved. After Phase 34 lands, the branch must be synchronized with the final Phase 34/main head, then PR #32 can be retargeted to `main` and requalified.

This prevents future-version preparation from weakening or bypassing the current release's required CI/release gates.

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

A queued/pending GitHub Actions run is not recorded as a pass. The next-version preflight result is only accepted after an exact-head completed workflow result is observed.

## Next implementation sequence

After Phase 34 is formatter/analyzer/test/audit/build clean and integrated:

1. synchronize/rebase the 2.1.0 preparation branch onto that exact base;
2. rerun and require the dedicated next-version preflight on the synchronized head;
3. decide and qualify the extension-safe Flutter/Web staging approach under Manifest V3 CSP;
4. add deterministic extension package/audit scripts;
5. regression-protect generated extension package inventory, permissions, local-only runtime code, versions, and checksums;
6. activate the 2.1.0 package identity atomically only when the migration gates are ready;
7. begin a fresh qualification record for the changed 2.1.0 scope;
8. qualify real Chromium/Firefox extension behavior before any support/publication claim.
