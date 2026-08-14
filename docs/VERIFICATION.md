# Verification Record

This document records objective automated evidence for the current 2048 Nova release-candidate line. It distinguishes formatter/analyzer/test/Web verification, native compilation evidence, transparent intermediate failures, and manual release boundaries.

## Phase 14 — Portable Game Backup + complete documentation

### Final permanent quality gate

The final Phase 14 source/test state was verified by the maintained `CI` workflow:

```text
Workflow: CI
Run: 31787639781
Verified source/test commit: 137180a1c886852e1b2b4dfda4bbcb514c927eb2
Conclusion: SUCCESS
```

All maintained quality steps passed:

- dependency resolution — **PASS**
- Dart formatting check — **PASS**
- Flutter static analysis — **PASS**
- complete automated test suite — **PASS: 112/112**
- Flutter Web release build — **PASS**
- overall CI job — **SUCCESS**

Phase 13 completed at 92 tests. Phase 14 added exactly 20 focused tests:

- `test/game_backup_test.dart` — 7;
- `test/imported_game_policy_test.dart` — 5;
- `test/game_backup_screen_test.dart` — 4;
- `test/unranked_marker_test.dart` — 4.

Automated Phase 14 coverage verifies that backup round trip preserves the current game; unrelated lifetime/settings/achievement/Daily/Undo data is excluded; malformed/unsupported/invalid/oversized backup text is rejected; strict embedded `GameState` validation remains authoritative; clipboard export is decodable; import requires explicit confirmation; Cancel/invalid input preserve existing state; imported sessions remain unranked across restart; imported moves cannot mutate lifetime records, achievements, streaks, or Daily history; imported historical best cannot replace the device lifetime record; terminal imported state cannot award a ranked win; a normal new game exits imported policy; and malformed/cleared/corrupt current-game state cleans the associated unranked marker.

### Final native production gate

The clipboard production boundary was refactored behind `TextClipboard` so normal builds still use Flutter's system clipboard while widget tests use an in-memory implementation. The production state containing that abstraction and the injectable Game Backup screen was verified by the maintained native matrix:

```text
Workflow: Platform Builds
Run: 31787016748
Verified production commit: dd3c79bec40cf1aa1e4b00190d32393b249902e0
Commit message: refactor: inject clipboard service into game backup screen
Conclusion: SUCCESS
```

Jobs:

- Android release APK — **PASS**
- Linux release — **PASS**
- Windows release — **PASS**
- macOS release — **PASS**
- iOS release with `--no-codesign` — **PASS**

The iOS job is intentionally unsigned. Real signing/provisioning remains a manual distribution boundary.

An earlier Phase 14 native matrix (`31784286707` on `741dfd42e51386646aa64be116cf7e913e98d211`) had already passed all five configured targets before the clipboard abstraction. Run `31787016748` supersedes it for current Phase 14 production-code evidence.

### Transparent Phase 14 intermediate failures

These are not counted as final verification:

- CI run `31781326279` failed because strict analysis exposed an unused backup-test import. Commit `3446413574582c196a47877fe1bfbe63addbf71d` fixed it.
- The oversized-backup fixture initially used unsupported Dart string multiplication; commit `a4a2de5bfb9e32fb9f02cf13b5019f69141ff567` replaced it with a valid `List.filled(...).join()` fixture.
- Backup widget tests initially assumed the below-the-fold Home card was visible in Flutter's default 800×600 test viewport; commit `24b2063f365b63a86009c9acbebf2c4bafe73bed` added explicit scrolling.
- A later full suite completed with **110 passed / 2 failed** after the clipboard abstraction. Focused diagnostics showed only the Backup **export** and **cancel** widget cases failed because their page actions were still below the bottom navigation/test viewport. Commit `137180a1c886852e1b2b4dfda4bbcb514c927eb2` (`test: scroll backup page beyond bottom navigation before taps`) corrected those page-action taps. The maintained CI then passed **112/112** in run `31787639781`.
- Temporary one-time patch/wiring helpers had development-tooling failures (`31780514759`, `31780577741`, `31780703213`, `31780791461`, `31781232021`) and were removed after source changes were committed normally.
- Phase-14-log helper attempts `31785071035` and `31785159285` failed at workflow parsing; `31785331045` appended successfully in its temporary checkout but failed before commit because staging named an already-removed helper path. Final helper run `31785495844` completed successfully, appended Phase 14 to `what_changed.md`, committed it, and removed itself.
- Temporary Phase 14 diagnostic workflows were removed after they isolated the widget failures; they are not part of the permanent automation surface.

The maintained workflow directory is limited to:

- `bootstrap-branding.yml`
- `bootstrap-platforms.yml`
- `ci.yml`
- `format-code.yml`
- `lock-dependencies.yml`
- `platform-builds.yml`

## Historical Phase 13 — Move Replay

```text
Workflow: CI
Run: 31779838751
Verified commit: 278ba039d0b7b59ce54c72c5ed0fcd0401ba537a
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 55 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 92/92
Web release build: PASS — build/web
WASM dry run: PASS
Overall CI job: SUCCESS
```

Native matrix `31779566057` on production commit `4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd` passed Android release APK, Linux, Windows, macOS, and unsigned iOS.

Intermediate Replay CI run `31779369661` recorded 90 passing / 2 failing tests because the widget harness tapped below-the-fold controls without scrolling. Commit `501b2a512c2f185461129f2e294504e43e883d59` fixed the harness; the final 92-test gate above passed.

## Historical Phase 12 — Auto Play Demo

```text
Workflow: CI
Run: 31778558429
Commit: 1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 51 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 86/86
Web release build: PASS
```

Native matrix `31778424208` on production commit `a1cc17836834750c542c69ffdf3c5e582d4e43ab` passed Android, Linux, Windows, macOS, and unsigned iOS release builds.

## Historical Phase 11 — Deep hardening

```text
Workflow: CI
Run: 31777374553
Commit: 1ecbf0881f723af1829fda523752562660a86a98
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 47 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 81/81
Web release build: PASS
```

## What automated verification proves

A successful current quality gate provides evidence that the tested repository state is Dart-format clean, passes configured Flutter static analysis, passes the complete automated unit/widget regression suite, produces a Flutter Web release build, and preserves the tested deterministic/persistence/accessibility/Replay/Auto Play/Backup trust boundaries. A successful native matrix provides evidence that the relevant production code compiles as configured on GitHub-hosted Android/Linux/Windows/macOS/iOS runners.

## What automated verification does not prove

It does not prove universal absence of defects; every physical device or OS version; real touch/orientation behavior on all devices; final TalkBack/VoiceOver/Narrator/browser-screen-reader quality; every real clipboard/browser/email handler; long-duration lifecycle behavior; Android production keystore/store signing; Apple signing/provisioning/notarization; or store acceptance/final privacy-data-safety listing accuracy.

Those remain explicit tasks in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md).

## Release-candidate status

```text
Project: 2048 Nova
Version: 0.9.0+1
Stable 1.0.0 claim: NOT YET
```

Use this document with [`TESTING.md`](TESTING.md), [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), [`../CHANGELOG.md`](../CHANGELOG.md), and [`../what_changed.md`](../what_changed.md).
