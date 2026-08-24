# 2048 Nova 2.1.0 — Next-Version Preparation

Status: **preparation only**  
Current maintained package/build: `2.0.12+2012`  
Current marketing version: `2.0.12`  
Planned next marketing version: `2.1.0`

This document deliberately scopes the next release without changing the current Version 2.0.12 candidate or its manual qualification record. Version 2.0.12 remains the current source-complete release line until its maintenance and release gates are genuinely satisfied.

## Release theme

Version 2.1.0 is planned as a **platform-integration and browser-extension foundation release**. The goal is to make 2048 Nova easier to package in browser-extension environments while preserving the existing Android-first, six-target Flutter application and its deterministic/offline architecture.

The release must not turn the game into an online service, weaken local-data trust boundaries, or silently add broad browser permissions.

## Planned 2.1.0 goals

### 1. Browser-extension foundation

Prepare a browser-extension packaging layer that can reuse the existing deterministic game/domain code without coupling that code to browser APIs.

The initial target contract is:

- modern Manifest V3 packaging for Chromium-family browsers;
- WebExtensions-compatible structure for Firefox where practical;
- a small extension action/popup or similarly bounded first UI surface;
- local packaged code only;
- no remotely hosted executable code;
- no content scripts by default;
- no host permissions by default;
- no browsing-history, tabs, page-content, clipboard, camera, or network permissions unless a concrete future feature requires them and the permission is documented, regression-tested, and user-visible;
- extension storage only when an adapter is intentionally selected; core gameplay must remain independent of extension storage APIs;
- English/Hindi UI parity where the extension surface exposes user-facing text;
- accessibility and keyboard behavior retained for extension UI.

Chrome's current extension platform uses Manifest V3. Manifest V3 moves background work to service workers and disallows remotely hosted executable code. Firefox WebExtensions has Manifest V3 support but retains browser-specific manifest fields and signing/distribution differences. The implementation must therefore use a shared manifest-generation/configuration model rather than assuming every browser accepts one identical manifest unchanged.

Official references used for this preparation:

- Chrome Extensions Manifest V3 overview: https://developer.chrome.com/docs/extensions/develop/migrate/what-is-mv3
- Chrome extension manifest reference: https://developer.chrome.com/docs/extensions/reference/manifest
- Chrome extension development overview: https://developer.chrome.com/docs/extensions/develop
- Mozilla WebExtensions manifest reference: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json
- Mozilla `browser_specific_settings`: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/browser_specific_settings

### 2. Extension-safe Web build investigation

The existing Flutter Web/PWA build is a first-class target, but a browser extension has a different Content Security Policy and execution environment.

Before declaring extension support, Version 2.1.0 must explicitly qualify:

- whether the current Flutter Web renderer/bootstrap can run under the selected Manifest V3 extension CSP without unsafe workarounds;
- whether WebAssembly or generated JavaScript requires extension-specific CSP entries;
- whether the extension can remain fully packaged/local with no remote runtime code;
- whether extension pages need a dedicated build configuration separate from the normal PWA output;
- extension popup sizing and responsive layout behavior;
- keyboard focus and accessibility semantics inside extension UI;
- storage behavior and migration boundaries between normal Web/PWA storage and extension storage;
- browser reload/update behavior without corrupting a saved game;
- Chrome/Chromium and Firefox packaging differences.

The repository must not claim extension support merely because `flutter build web` succeeds.

### 3. Keep Android and the six-target app first-class

2.1.0 preparation must not regress the existing Android, iOS, Web/PWA, Windows, macOS, or Linux targets.

Required guarantees remain:

- Android APK and AAB builds;
- unsigned iOS release compilation in hosted qualification;
- Web/PWA release build and checksummed package;
- Windows, macOS, and Linux release builds;
- shared gameplay behavior and deterministic engine;
- local save/resume and bounded Undo;
- Hint, Auto Play, replay, Challenge Code, Daily Challenge, backup, localization, accessibility, and settings behavior;
- fail-closed release/audit tooling.

Browser-extension work must be additive. It is not permitted to simplify the repository by removing an existing platform runner.

### 4. Version migration must be atomic

When 2.1.0 is activated, update all release identity surfaces together. At minimum review and synchronize:

- `pubspec.yaml`;
- `lib/core/constants/project_info.dart`;
- Windows fallback resources;
- Android/iOS/macOS platform version behavior where Flutter supplies values;
- `docs/release_qualification.json`;
- release-readiness tooling;
- repository/source-completion/version audits;
- current-state/version regression fixtures;
- README, roadmap, security, build, release, dependency, support, and verification documentation;
- `CHANGELOG.md`;
- `what_changed.md`;
- extension manifest/package version once extension packaging exists.

A partial version bump is a release error.

## Planned architecture boundary

The preferred architecture is adapter-first:

```text
shared deterministic domain/data behavior
              |
              v
       application state layer
              |
      +-------+-------+
      |               |
      v               v
Flutter app host   extension host adapter
Android/iOS/...    browser-specific packaging/API bridge
```

The domain engine must never import browser-extension APIs. Browser APIs belong in a narrow adapter/host layer.

## Browser-extension directory preparation

A future implementation may introduce a structure similar to:

```text
extension/
  README.md
  manifests/
    chromium/
    firefox/
  src/
  scripts/
  assets/
```

This layout is **not** a commitment to duplicate game logic. Generated extension UI assets should come from a documented build pipeline, while browser-specific manifests/adapters remain small and reviewable.

## Permission policy

The first extension-capable release should prefer **zero optional browser privileges beyond those strictly required to render its own packaged UI**.

Any future requested permission must document:

1. the exact feature requiring it;
2. why a less-privileged design is insufficient;
3. which browsers require it;
4. what user data becomes visible to the extension;
5. whether data leaves the device;
6. how the user can revoke or avoid the permission;
7. automated regression coverage;
8. manual browser-store/privacy review requirements.

Broad host access such as `<all_urls>` is not an acceptable default for a standalone 2048 game.

## Privacy and trust requirements

The current offline-first model remains the default:

- no account requirement;
- no advertising requirement;
- no telemetry requirement;
- no cloud-save requirement;
- no remote AI requirement;
- no browsing-data collection;
- no page-content collection;
- no hidden network dependency for gameplay.

If a later 2.1.x feature intentionally changes one of these boundaries, it requires a separate explicit design/security/privacy review.

## 2.1.0 preparation gates

Before the package version is changed from 2.0.12 to 2.1.0, all of the following should be true:

- Phase 34 maintenance changes are integrated or deliberately superseded;
- current Dart formatting, analysis, tests, repository audits, source-completion checks, and Web build are green on the integration base;
- the next-version scope is indexed in the documentation;
- a machine-readable next-version preflight identifies every version-coupled source surface;
- extension support is still described as preparation unless a real extension package has been built and manually loaded in representative browsers;
- current 2.0.12 manual evidence is preserved historically rather than rewritten as 2.1.0 evidence.

## Initial 2.1.0 implementation phases

### Phase A — migration/preflight infrastructure

- add a next-version migration preflight;
- protect the target `2.1.0` identity and migration file list;
- document browser-extension architecture and permissions;
- add CI/documentation regression coverage.

### Phase B — extension host prototype

- add the smallest extension host/package skeleton;
- use Manifest V3 for Chromium packaging;
- add Firefox-specific manifest metadata only where required;
- keep permissions minimal;
- verify local-only code packaging.

### Phase C — extension UI integration

- connect the shared application/game surface without duplicating game rules;
- qualify popup/window sizing, keyboard focus, localization, themes, reduced motion, and accessibility;
- add extension-specific storage adapter only if required.

### Phase D — build and browser qualification

- deterministic extension packaging command;
- package integrity/checksum output;
- automated manifest/package audit;
- manual unpacked install/load/update/restart/save-resume checks on representative Chromium and Firefox versions;
- store-policy/privacy metadata review before any publication claim.

## Explicit non-goals for the preparation stage

This preparation does not claim or require:

- Chrome Web Store publication;
- Firefox Add-ons publication;
- Safari extension packaging;
- content-script injection;
- page modification;
- tab/history/bookmark access;
- browser-wide keyboard interception;
- cloud synchronization;
- online multiplayer;
- remote analytics or advertising.

Those require deliberate future scope rather than permission creep.

## Version activation rule

Do not change the current package to `2.1.0` merely because this preparation document exists. The version is activated only by an intentional migration commit series that updates the complete release identity contract and starts a new qualification manifest for 2.1.0 while preserving Version 2.0.12 evidence as historical data.
