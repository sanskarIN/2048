# Browser Extension Foundation

This document defines the browser-extension architecture planned for the 2048 Nova 2.1.0 release line. It is a design and qualification contract, not a claim that a publishable extension already exists.

Current application support remains Android, iOS, Web/PWA, Windows, macOS, and Linux. Browser-extension packaging is additive and must not replace or weaken those targets.

## Design principles

1. **Reuse game logic, not browser assumptions.** The deterministic engine, rules, solver, replay, backup validation, Challenge Code logic, and trusted-state boundaries stay browser-agnostic.
2. **Least privilege.** The extension should request no host/page/browser permissions unless a specific implemented feature truly needs them.
3. **Packaged/local execution.** Extension runtime code must ship inside the extension package. Remote executable code is not part of the design.
4. **Offline-first behavior.** Core gameplay must remain usable without an account, telemetry service, advertisement network, cloud database, or remote AI service.
5. **Cross-browser preparation.** Chromium and Firefox share WebExtensions concepts but have manifest/API/signing differences. Browser-specific metadata belongs in a narrow packaging layer.
6. **No false support claims.** A normal Flutter Web build is not proof that the generated output is extension-CSP-compatible.

## Platform baseline

### Chromium-family browsers

The Chromium package must use the current Manifest V3 extension model.

The initial extension surface should be intentionally small. Preferred first options are:

- a toolbar action with a popup; or
- a dedicated extension page opened explicitly by the user.

A side panel can be considered later if it materially improves playability and has acceptable cross-browser parity.

The initial package should not require:

- content scripts;
- host permissions;
- tab access;
- browsing-history access;
- bookmark access;
- arbitrary page injection;
- page-content collection.

### Firefox

Firefox support should use the same shared extension assets where possible, with Firefox-specific manifest metadata isolated in the Firefox packaging layer.

The implementation must account for:

- extension signing/ID requirements;
- `browser_specific_settings` where required;
- Firefox-specific data-collection declaration requirements for distribution;
- API namespace/compatibility differences;
- different store packaging and review rules.

The shared game/domain layer must not contain Firefox-specific conditionals.

## Proposed repository layout

The browser-extension source should live outside the normal Flutter platform runner directories so the existing six-target contract remains clear.

Proposed structure:

```text
extension/
  README.md
  assets/
  manifests/
    chromium/
      manifest.json
    firefox/
      manifest.json
  scripts/
    build_extension.dart-or-script
    audit_extension.dart-or-script
  web/
    generated-or-staged-extension-ui
```

The final build may use a different exact structure after the Flutter/CSP investigation. The important boundary is that browser-specific manifests and packaging logic remain separate from `lib/domain/`.

## Manifest contract

A minimal Chromium manifest is expected to include only required identity and UI fields at first.

Conceptual shape:

```json
{
  "manifest_version": 3,
  "name": "2048 Nova",
  "version": "2.1.0",
  "action": {
    "default_popup": "index.html"
  }
}
```

This is a design illustration, not the final package manifest. The actual implementation must add icons, description/localization, CSP, and any browser-specific fields deliberately.

Firefox packaging may need a separate manifest overlay such as `browser_specific_settings`. Do not add browser-specific keys to shared runtime game code.

## Permission contract

### Default policy

The first extension package should aim for no optional privileges beyond rendering and storing its own packaged application data.

### Permission review template

Every requested browser permission must answer:

| Question | Required answer |
| --- | --- |
| What user-visible feature needs this? | Exact implemented feature. |
| Can the feature work without the permission? | Explain the least-privileged alternative review. |
| Which browsers need it? | Chromium / Firefox / both / browser-specific. |
| What data becomes readable or writable? | Exact data categories. |
| Does any data leave the device? | Yes/no, with destination and reason if yes. |
| Can the user avoid/revoke it? | User-control behavior. |
| What automated test protects it? | Test/audit path. |
| What manual qualification is needed? | Browser/store/privacy check. |

Permissions should never be added merely because they might be useful later.

## Storage boundary

The extension may eventually need a storage adapter, but the adapter must preserve current trust semantics.

Requirements:

- domain models remain independent of extension storage APIs;
- persisted data stays validated and bounded;
- corrupted/partial extension storage cannot crash the game;
- imported/portable data remains unranked under existing trust rules;
- extension storage migrations are versioned and tested;
- clearing extension data has an understandable user-facing effect;
- normal Web/PWA storage and extension storage are not assumed to share the same namespace or lifecycle.

A proposed abstraction is:

```text
Game persistence contract
        |
        +-- existing local Flutter/Web adapter
        |
        +-- extension storage adapter (only if required)
```

## Flutter Web and extension CSP investigation

Manifest V3 extension pages use a more restrictive execution environment than an ordinary deployed website. Before an extension build is declared supported, the generated Flutter output must be tested inside the extension context.

Qualification questions:

- Does the selected Flutter renderer execute under extension CSP without forbidden dynamic-code behavior?
- Does generated JavaScript require CSP allowances that the store would reject?
- If WebAssembly is used, which extension CSP directives are needed?
- Does the Flutter bootstrap assume a normal HTTP deployment path?
- Are asset URLs resolved correctly with extension URLs?
- Can the UI start without network access?
- Do fonts/icons remain fully packaged?
- Does the popup remain usable at realistic extension dimensions?
- Does focus enter the Flutter surface correctly?
- Are keyboard arrows and shortcuts captured only while the game has focus?
- Do screen-reader semantics remain available?

If the normal Flutter Web bundle is not suitable, create a dedicated extension build/staging pipeline rather than weakening extension security policy.

## UI scope for the first extension prototype

The first prototype should prove the architecture with the smallest useful player surface.

Suggested prototype capabilities:

- start/resume a Classic game;
- move with keyboard and pointer/touch where available;
- score and best-score display;
- New Game;
- Undo within the existing bounded rules;
- theme/localization state if persistence is already available;
- explicit link to open the full application experience if a larger surface is needed.

Do not duplicate the game engine in JavaScript just to make the prototype easier. The purpose of 2.1.0 preparation is reuse and maintainability.

## Features that may remain full-app-only initially

An extension prototype does not have to expose every mature feature on day one.

The following can remain in the full app until their extension UX is qualified:

- large replay archive management;
- file backup import/export;
- long statistics/achievement screens;
- detailed guide/about screens;
- Auto Play diagnostics;
- full QR display workflows.

Their underlying data/domain logic must remain reusable, and extension parity can be added deliberately rather than creating cramped or inaccessible UI.

## Build pipeline goals

The final 2.1.0 build pipeline should provide deterministic commands for at least:

```text
build Chromium extension package
build Firefox extension package
validate manifests
verify packaged file allowlist
verify no remote executable code references
verify permission allowlist
produce archive checksum
```

The package audit should fail closed when unexpected permissions, remote script URLs, missing icons, invalid versions, or required files are detected.

## CI goals

Once extension source is activated, CI should add a dedicated extension qualification job that does not weaken the existing app jobs.

Expected automated checks:

- manifest JSON parse/contract tests;
- Chrome MV3 version requirement;
- Firefox-specific settings validation;
- permission allowlist;
- no remote executable-code references;
- extension package construction;
- deterministic package file inventory where practical;
- SHA-256 checksum creation;
- extension UI static/build smoke check;
- documentation/audit wiring.

Automated packaging does not replace manually loading the extension in real browsers.

## Manual browser qualification

Before claiming supported extension status, perform representative checks for each declared browser family:

- load unpacked/development package;
- first launch;
- new game and movement;
- save/resume after popup/page close;
- extension reload/update;
- browser restart;
- keyboard focus and arrow keys;
- high contrast/reduced motion/theme behavior;
- English/Hindi text;
- screen-reader semantics;
- permission presentation (if any);
- offline launch;
- package/update behavior;
- browser console errors;
- store metadata/privacy declarations before publication.

Evidence must identify browser/version, OS, extension package commit/hash, result, and explicit-timezone timestamp.

## Security boundaries

The extension must preserve these existing project rules:

- portable codes/checksums are validation, not authentication;
- imported progress does not become trusted ranked progress;
- external navigation remains explicit and validated;
- no secret signing/store credentials are committed;
- no arbitrary eval or remote-code workaround is introduced just to make the Flutter bundle run;
- no page-wide privilege is requested for a feature that only needs the extension's own UI.

## Cross-platform regression rule

Adding `extension/` must not remove or bypass:

```text
android/
ios/
web/
windows/
macos/
linux/
```

The extension becomes a seventh distribution surface, not a replacement for the existing six Flutter target families.

## Activation status

Current status: **design prepared; extension source/package not yet activated**.

The next implementation step is to add a machine-readable 2.1.0 migration contract and preflight, then prototype the extension build only after the Phase 34 maintenance base is formatter/analyzer/test clean.
