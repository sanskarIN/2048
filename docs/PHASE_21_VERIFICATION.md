# Phase 21 Verification — Offline Challenge Code QR Rendering

Date: **2026-08-15**

## Scope

Phase 21 adds local QR **rendering only** for the existing versioned `NOVA1` Challenge Code text. It does not add a second Challenge Code protocol, in-app scanning, camera permission, a network QR-generation service, an account, cloud transfer, or a new trust path.

Implemented runtime surface:

- pinned `qr_flutter 4.1.0` presentation dependency;
- project-owned `ChallengeCodeQr` wrapper;
- exact canonical `NOVA1...` text passed to the QR renderer;
- automatic QR version selection;
- fixed black data/eye modules on a white QR surface regardless of surrounding app theme;
- normal render size capped at 260 logical pixels;
- width constrained to the actual parent on narrower layouts;
- localized semantic label and local render-error fallback;
- generated selectable/copyable text retained beside the QR as a non-visual/non-scanning fallback;
- English/Hindi QR sharing, trust, accessibility, privacy, Guide, and About copy;
- no controller, persistence, analytics, networking, camera, scanner, or trusted-progress dependency in the QR widget.

A QR image is only another representation of the existing plain Challenge Code string. Text obtained by an external camera/scanner must still enter through the ordinary `ChallengeCode.decode()` validation and existing game-replacement flow. The FNV-1a checksum remains accidental-corruption detection only; neither the text nor QR proves authorship, identity, fairness, anti-cheat status, or authenticity.

## Focused implementation acceptance

The final successful implementation helper was:

```text
Workflow run: 31877104598
Job: 94994366934
Result: SUCCESS
Focused Challenge Code tests: 15/15 PASS
```

That focused gate covered the existing Challenge Code codec/screen behavior plus the first QR integration and Hindi screen behavior before the later component/localization regressions expanded the full suite.

## Phase 21 automated test growth

Phase 20 ended at **189 tests**. Phase 21 adds five net new regressions, bringing the maintained suite to **194 tests**:

1. generated Challenge Code QR is localized in Hindi;
2. project QR wrapper receives the exact portable Challenge Code text;
3. QR rendering is capped at 260 logical pixels;
4. QR rendering stays within a narrower available width without overflow;
5. Hindi catalog covers the new QR trust/accessibility guidance.

The existing Challenge Code tests continue to cover deterministic mode/seed round trips, checksum rejection, malformed/oversized input rejection, Daily Challenge isolation, copy/paste/manual flows, replacement protection, and deterministic starting state.

## Transparent implementation-helper failures

Phase 21 intentionally retains the helper failures rather than rewriting the history as an uninterrupted success.

### Helper attempt 1 — workflow registration failure

```text
Staging commit: be5664ecc210b37b18ce46501215a2f6c21bb2c5
Workflow run: 31876872179
Result: FAILURE / no implementation jobs published
Cleanup: 41bb6a3804627b438eaeb2795618bfb88c76f6b3
```

The first temporary implementation workflow did not produce usable source commits. It was removed before the implementation path was redesigned.

### Helper attempt 2 — test API mismatch

```text
Script staging: 1f1196a4f4750b46950931dc3365dd59641f270a
Workflow staging: e26676b4aaa73b1cb567c1c802c996b7bbef4edc
Workflow run: 31876914197
Job: 94993915532
Result: FAILURE
```

The test tried to read `QrImageView.data` even though `data` is accepted by the package constructor but is not exposed as a public getter in `qr_flutter 4.1.0`. Production QR behavior was not changed to satisfy the test. Commit `989b2d41b7506bc13a2c143043213c2d09122207` corrected the assertion to verify the exact payload through the project-owned `ChallengeCodeQr.code` contract.

### Helper attempt 3 — focused tests green, rebase blocked by Flutter workspace rewrite

```text
Retry trigger: 071694bc058ee5e28dddb01499caad1a84fcc8cf
Workflow run: 31876990559
Job: 94994098270
Focused tests: 15/15 PASS
Final result: FAILURE during synchronization
```

The implementation itself passed its focused tests, but Flutter rewrote `analysis_options.yaml` in the runner workspace and `git pull --rebase` refused to proceed with the unstaged edit. The generated commits therefore were not treated as published evidence.

### Helper attempt 4 — focused tests green, additional generated workspace changes blocked rebase

```text
Sync-fix commit: 605a9c1c036b569d6fe2e35fec6ea4fb48095cfb
Workflow run: 31877037878
Job: 94994207117
Focused tests: 15/15 PASS
Final result: FAILURE during synchronization
```

A second rebase-based synchronization attempt still encountered generated workspace changes. The final helper was simplified to a direct fast-forward push from the current `main` checkout, with generated workspace noise discarded only after the already-tested commits were published.

### Final implementation helper

```text
Synchronization fix: 226a577e70e416b8dd09bc220eaa69d174bfefed
Workflow run: 31877104598
Job: 94994366934
Result: SUCCESS
Focused tests: 15/15 PASS
```

The helper published the separate production, Hindi localization, regression-test, dependency-lock, and formatting commits, then removed its temporary script/workflow.

## Responsive QR correction

The first reusable QR widget imposed a 180 logical-pixel minimum even when its parent was narrower. That could force horizontal overflow in unusually constrained layouts.

Correction:

```text
be553b2100a6171c4c149a6832b4c8d75ae90546
fix: keep Challenge QR within narrow layouts
```

The wrapper now uses the bounded parent width when available, caps the result at 260 logical pixels, and never invents a larger minimum than the parent can provide. `test/challenge_code_qr_test.dart` independently covers the exact payload, 260-pixel cap, and narrow-layout containment.

## Product-copy and documentation gates

Localized Guide/About/trust/accessibility copy was applied by:

```text
Workflow run: 31877255494
Job: 94994722496
Result: SUCCESS
```

The complete documentation pass was applied by:

```text
Workflow run: 31877375454
Job: 94994996845
Result: SUCCESS
Cleanup commit: 844ed15180402b8f609e20c9c3f816e71ebef96e
```

That pass synchronized README, roadmap, changelog, Challenge Code specification, dependencies, privacy, accessibility, security, architecture, development, testing, release checklist, platforms, CI/CD, user guide, FAQ, troubleshooting, contributing guidance, documentation index, and localization notes. Stale claims that Challenge Codes used no QR/runtime package were removed; the project now distinguishes the unchanged codec/trust model from the new presentation-only QR dependency.

## First final-source gate — formatting failure

The first source-freeze trigger was:

```text
Commit: 1ab945fa3d483090c5c8290e52331c237f86ca5c
CI run: 31877417527
CI job: 94995089241
Result: FAILURE at formatting
Files checked: 94
Files needing canonical formatting: 32
```

This was broader Dart 3.13 formatting drift across existing `lib/` and `test/` files, not a QR logic failure. Analyzer, tests, and Web were not used as acceptance evidence from that run because the formatting gate correctly stopped first.

The maintained formatter normalized the current tree:

```text
Formatter workflow run: 31877417558
Formatter job: 94995089435
Commit: 03f26863462609b3b7ff33b0bce81640580fbe18
Message: style: format Dart sources and tests
Result: SUCCESS
```

Because the token-authenticated formatter push did not fan out new workflows, a final meaningful source-contract commit was used to trigger the permanent gates on the formatted runtime:

```text
2678e65824ca088c4ba93342bc8737fc18ec7708
docs: codify Challenge QR scan contrast in source
```

## Final current-source CI

The complete formatted Phase 21 runtime passed the permanent CI workflow:

```text
Commit: 2678e65824ca088c4ba93342bc8737fc18ec7708
CI run: 31877515001
CI job: 94995319221
Result: SUCCESS
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 94 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 194/194
Web release: PASS — build/web
Web WASM dry run: PASS
```

The Web build again emitted the existing non-fatal Cupertino icon-font availability warning while successfully producing `build/web`. No speculative icon dependency was added because this warning is not a build failure and is not caused by Phase 21 QR rendering.

## Final current-source native matrix

The same exact runtime commit passed the permanent multi-platform build workflow:

```text
Commit: 2678e65824ca088c4ba93342bc8737fc18ec7708
Platform Builds run: 31877514960
Result: SUCCESS
Android release APK: PASS — job 94995348734
Linux release: PASS — job 94995348682
Windows release: PASS — job 94995348743
macOS release: PASS — job 94995348674
unsigned iOS release: PASS — job 94995348674
```

This is the accepted Phase 21 native compilation evidence. It verifies that the pinned QR-rendering dependency and completed runtime source compile across all configured native target families. It does **not** verify optical QR scanning quality on physical displays.

## Manual release boundary

Hosted tests and builds do not replace representative real-environment qualification. Before stable `1.0.0`, Phase 21 still needs manual checks for:

- device-to-device scanning of the displayed QR using external camera/scanner applications;
- confirmation that scanned text exactly matches the visible/selectable `NOVA1...` code;
- representative display density, brightness, glare, orientation, and viewing-distance behavior;
- light/dark surrounding themes while the QR itself remains black on white;
- narrow layouts, large text, high contrast, keyboard/focus, and screen-reader semantics;
- verification that selectable/copyable/manual text remains a usable fallback;
- confirmation that 2048 Nova itself never requests camera permission for QR rendering;
- confirmation that externally scanned text still passes ordinary Challenge Code validation and replacement protection.

All previously documented manual release boundaries also remain: physical Android/iOS gameplay and lifecycle/save-resume, Challenge Code clipboard handlers, Game Backup file/document-provider handlers, Move Replay and Full Replay Archive interaction/accessibility, external browser/email handlers, native splash/icon review, long-session/performance checks, signing/provisioning/notarization, and final store/package metadata review.

Stable `1.0.0` therefore remains intentionally unpromoted.
