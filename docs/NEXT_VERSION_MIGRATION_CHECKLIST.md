# Next-Version Migration Checklist — 2.1.0

This checklist controls the eventual activation of **2048 Nova 2.1.0**. It intentionally separates **preparation** from the later **version activation** commit series.

Current release identity remains:

```text
Marketing version: 2.0.12
Package/build version: 2.0.12+2012
Manual qualification: 0/13 recorded passed evidence
```

Planned next marketing version:

```text
2.1.0
```

No item in this file by itself changes the active package version.

## A. Base-integration gate

Before activating 2.1.0:

- [ ] Phase 34 audit/CI hardening is merged or deliberately superseded.
- [ ] `dart format --output=none --set-exit-if-changed lib test tool` passes on the exact integration base.
- [ ] `flutter analyze` passes.
- [ ] `flutter test --coverage` passes.
- [ ] candidate release-readiness metadata gate passes for the current release base.
- [ ] repository audit passes.
- [ ] cross-platform support audit passes.
- [ ] source-completion audit passes for the completed 2.0.12 base.
- [ ] solver benchmark smoke passes.
- [ ] Web release build passes without the protected missing-font warning.
- [ ] required native/platform build evidence is reviewed for the exact base when applicable.

Do not carry a known failing base into the version migration merely to obtain a new version number.

## B. Preserve 2.0.12 evidence

Before resetting any qualification state for the new release:

- [ ] preserve the Version 2.0.12 qualification manifest/evidence as historical material;
- [ ] preserve exact automated run IDs/commit hashes that genuinely apply to 2.0.12;
- [ ] do not relabel 2.0.12 device/browser/store evidence as 2.1.0 evidence;
- [ ] retain changelog and continuity history;
- [ ] retain the Version 2.0.12 final source-audit record.

A new release requires new evidence where the changed scope can affect real-world behavior.

## C. Activate package identity atomically

When the 2.1.0 activation is intentionally started, update the complete identity contract together.

Review at minimum:

- [ ] `pubspec.yaml` package/build version;
- [ ] `lib/core/constants/project_info.dart` marketing version;
- [ ] `windows/runner/Runner.rc` fallback numeric/string version;
- [ ] `docs/release_qualification.json` candidate/version and new-release qualification state;
- [ ] `tool/release_readiness.dart` target release;
- [ ] `tool/repository_audit.dart` canonical package/marketing contract;
- [ ] `tool/source_completion_audit.dart` release-scope/completion contract, if it remains applicable to the new release;
- [ ] current-version and release-gate fixtures;
- [ ] platform/version regression tests;
- [ ] `README.md`;
- [ ] `ROADMAP.md`;
- [ ] `SECURITY.md` current supported release line;
- [ ] `CHANGELOG.md`;
- [ ] `what_changed.md`;
- [ ] `docs/README.md`;
- [ ] build/release/qualification documentation;
- [ ] dependency/toolchain documentation where version text is current-state material;
- [ ] extension manifest/package version once the extension package becomes active.

A migration is incomplete if any authoritative current-state surface still claims the old release as current unintentionally.

## D. Browser-extension source activation gate

Before turning `extension/manifests/**/manifest.template.json` into active package manifests:

- [ ] extension UI build/staging command exists and is documented;
- [ ] generated/staged UI is local-only and contains no remote executable code;
- [ ] Chromium manifest uses Manifest V3;
- [ ] Firefox-specific metadata is isolated and validated;
- [ ] no host permissions are requested by default;
- [ ] no broad browser permissions are requested by default;
- [ ] no content scripts are registered by default;
- [ ] extension Content Security Policy compatibility is verified for generated Flutter/Web assets;
- [ ] packaged assets resolve with extension URLs;
- [ ] fonts/icons are packaged locally;
- [ ] extension startup works without network access;
- [ ] popup/page dimensions remain usable;
- [ ] keyboard focus and movement controls are qualified;
- [ ] English/Hindi user-facing strings are reviewed;
- [ ] accessibility/reduced-motion/high-contrast behavior is reviewed;
- [ ] extension persistence strategy is explicit and corruption-safe;
- [ ] package file inventory is audited;
- [ ] package SHA-256 checksum is generated;
- [ ] unpacked/development installation is manually tested on representative Chromium;
- [ ] development installation is manually tested on representative Firefox.

Until these checks exist, extension templates remain preparation artifacts and must not be advertised as supported distribution packages.

## E. Permission escalation gate

If any extension permission is proposed, document and review all of the following before merging it:

- [ ] exact user-visible feature;
- [ ] least-privileged alternatives considered;
- [ ] browser families needing the permission;
- [ ] exact data made readable/writable;
- [ ] whether data leaves the device;
- [ ] user avoidance/revocation behavior;
- [ ] automated permission allowlist regression;
- [ ] privacy/security documentation update;
- [ ] browser-store disclosure impact;
- [ ] manual qualification requirement.

`<all_urls>` or equivalent broad host access is not an acceptable default for a standalone puzzle game.

## F. New 2.1.0 qualification manifest

When 2.1.0 activates:

- [ ] start a new candidate qualification state tied to the new package/build version;
- [ ] carry forward only evidence that is legitimately invariant and explicitly justified by policy;
- [ ] reset changed-scope real-world checks to pending;
- [ ] add browser-extension checks if extension support is part of the release claim;
- [ ] require explicit-timezone timestamps for recorded evidence;
- [ ] keep stable promotion fail-closed until all required evidence is complete.

Potential extension-specific manual IDs should cover at least:

```text
extension-chromium-load
extension-firefox-load
extension-save-resume
extension-update-restart
extension-keyboard-focus
extension-accessibility
extension-localization
extension-offline
extension-permission-review
extension-package-review
```

Exact IDs should be finalized only when the supported extension scope is concrete.

## G. CI and package-audit activation

When extension source becomes active, add permanent automated checks for:

- [ ] manifest JSON parsing;
- [ ] Chromium `manifest_version == 3`;
- [ ] Firefox-specific settings schema used by the project;
- [ ] browser/host permission allowlist;
- [ ] absence of remote executable-code references;
- [ ] required local assets;
- [ ] package version synchronization;
- [ ] deterministic package creation where practical;
- [ ] ZIP/package checksum output;
- [ ] extension documentation/audit wiring;
- [ ] regression protection that existing Android/iOS/Web/Windows/macOS/Linux builds remain present.

The extension must become a seventh distribution surface, not replace one of the six Flutter target families.

## H. Documentation activation

Before a 2.1.0 release claim:

- [ ] public README describes only actually supported extension browsers/features;
- [ ] user guide explains extension controls/data behavior;
- [ ] privacy/security docs identify extension storage/permissions accurately;
- [ ] platform/build docs include extension build/package commands;
- [ ] troubleshooting includes extension load/CSP/storage diagnostics;
- [ ] release artifacts docs identify extension package/checksum;
- [ ] support docs explain how to report browser/extension version;
- [ ] changelog distinguishes preparation from activated support;
- [ ] `what_changed.md` records the exact migration/qualification boundary.

## I. Stable 2.1.0 promotion

Do not promote 2.1.0 as stable until:

- [ ] all permanent automated gates are green for the exact release commit;
- [ ] every claimed platform/distribution package has current build evidence;
- [ ] every required real-world qualification check has genuine evidence;
- [ ] browser extension support, if claimed, has real-browser load/use/update/offline/accessibility evidence;
- [ ] signing/store metadata/privacy disclosures are complete for distributions being published;
- [ ] no release-blocking defect remains;
- [ ] stable release-readiness command exits successfully for the exact 2.1.0 commit.

## Related preparation sources

- `docs/NEXT_VERSION_2_1_0.md`
- `docs/BROWSER_EXTENSION_FOUNDATION.md`
- `tool/next_version_contract.json`
- `extension/README.md`
- `extension/manifests/chromium/manifest.template.json`
- `extension/manifests/firefox/manifest.template.json`
