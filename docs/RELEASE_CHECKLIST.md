# Release Checklist — Version 2.0.12

2048 Nova is currently on the **Version 2.0.12** release target.

```text
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
Manual qualification: 0/13 passed
```

This checklist deliberately separates **source-controlled readiness**, **current-head automated verification**, and **real-world qualification**. Historical Version 1.5 CI/native results remain useful baseline evidence, but they are not automatically treated as proof that the Version 2.0.12 head passed the same jobs.

## 1. Version 2.0.12 source contract

These items are implemented in source and protected by regression/audit rules:

- [x] `pubspec.yaml` uses `2.0.12+2012`.
- [x] `ProjectInfo.version` uses `2.0.12`.
- [x] Windows fallback metadata uses `2,0,12,2012` / `2.0.12`.
- [x] `docs/release_qualification.json` candidate is `2.0.12+2012`.
- [x] `tool/release_readiness.dart` targets exact Version `2.0.12` with an optional numeric build suffix.
- [x] The gate rejects the former Version 1.5 line and unrelated 2.0 patch versions.
- [x] Stable mode requires a `## [2.0.12]` changelog section.
- [x] Stable mode remains fail-closed while any canonical manual check lacks genuine passed evidence.
- [x] `tool/repository_audit.dart` enforces package/runtime/Windows/qualification/continuity version alignment.
- [x] Phase 31 continuity is preserved in `what_changed_archive_phase_31.md`.
- [x] Phases 0–30 remain preserved in `what_changed_archive_phase_00_30.md`.
- [x] `what_changed.md` identifies Phase 32 and the 0/13 real-world qualification boundary.
- [x] Version 2.0.12 migration is documented in `PHASE_32_VERSION_2_0_12.md`.

## 2. Current-head automated release gate

The following must be green on the **exact Version 2.0.12 release candidate commit** before stable promotion. They remain unchecked here until a complete maintained result is actually observed and recorded for the current source state.

- [ ] `flutter pub get` completes successfully.
- [ ] `pubspec.lock` remains synchronized after dependency resolution.
- [ ] `analysis_options.yaml` remains synchronized after Flutter tooling.
- [ ] `dart format --output=none --set-exit-if-changed lib test tool` passes with no changes.
- [ ] `flutter analyze` reports no issues.
- [ ] `flutter test --coverage` passes the complete current test suite.
- [ ] `dart run tool/release_readiness.dart --json` passes candidate mode for `2.0.12+2012`.
- [ ] `dart run tool/release_qualification_status.dart --json --pending-only` validates the canonical manifest.
- [ ] `dart run tool/repository_audit.dart --json` passes.
- [ ] Normal CI confirms `--stable` remains closed while manual evidence is incomplete.
- [ ] `dart run tool/solver_benchmark.dart 8` passes deterministic solver smoke checks.
- [ ] `flutter build web --release` succeeds without the guarded missing-icon-font warning.
- [ ] Android release APK builds on the maintained hosted toolchain.
- [ ] Android release AAB builds on the maintained hosted toolchain where configured.
- [ ] Linux release build succeeds.
- [ ] Windows release build succeeds.
- [ ] macOS release build succeeds.
- [ ] unsigned iOS release compilation succeeds.
- [ ] Native qualification artifacts are packaged with SHA-256 sidecars.
- [ ] Expected artifacts upload successfully with the maintained retention policy.

When these are complete, record the exact commit SHA, workflow run IDs, job IDs, current test count, formatting file count, Flutter/Dart versions, and native-matrix result in `docs/VERIFICATION.md`, the Phase 32 record, and `what_changed.md`.

## 3. Core engine and persistence regression coverage

Before stable release, automated/current-head coverage must still verify:

- [ ] deterministic move/merge/spawn rules and one-merge-per-source-tile behavior;
- [ ] deterministic RNG preservation through save/resume and Undo;
- [ ] terminal win/game-over movement blocking;
- [ ] continue-after-win behavior;
- [ ] Time Challenge deadline/status reconciliation;
- [ ] Move Limit behavior;
- [ ] Daily Challenge deterministic date seed/history behavior;
- [ ] malformed save rejection and safe repair/removal paths;
- [ ] stale Undo filtering;
- [ ] statistics reset/Undo boundaries;
- [ ] trusted global and per-mode record behavior;
- [ ] imported backup ranking isolation;
- [ ] settings/statistics/achievement timestamp validation;
- [ ] project-owned Clear All behavior without unrelated preference deletion.

## 4. Challenge Code qualification

Automated/current-head checks must cover:

- [ ] deterministic supported configuration + seed round trip;
- [ ] same-code opening board/RNG reproducibility;
- [ ] prefix/segment/checksum/Base64URL/UTF-8/JSON validation;
- [ ] strict `GameConfig`/seed bounds;
- [ ] Daily Challenge exclusion;
- [ ] oversized/malformed input rejection;
- [ ] replacement confirmation behavior;
- [ ] QR rendering contains the exact existing `NOVA1` text;
- [ ] QR feature adds no camera permission or scanner dependency;
- [ ] English/Hindi labels and errors remain covered.

Manual real-target checks:

- [ ] Generate/copy/paste/manual-entry flow on representative platforms.
- [ ] Scan displayed QR with an external camera/scanner and verify exact text round trip.
- [ ] Verify two independent sessions using the same code start identically.
- [ ] Verify identical valid move sequences preserve deterministic spawn sequence.
- [ ] Verify invalid/corrupt/oversized codes never replace current progress.
- [ ] Verify large text, keyboard/focus, TalkBack/VoiceOver/browser-screen-reader behavior.

These real-target results belong under qualification ID `challenge-code-real-target`.

## 5. Move Replay qualification

Automated/current-head checks must cover:

- [ ] validated bounded Undo snapshots only;
- [ ] stale/future snapshot filtering;
- [ ] defensive immutable replay copies;
- [ ] first/previous/next/latest and slider behavior;
- [ ] play/pause and 1/2/4 FPS behavior;
- [ ] no live board/score/RNG/statistics mutation;
- [ ] no lingering playback timer after navigation;
- [ ] bounded-history disclosure.

Manual real-target checks:

- [ ] scrub/play/pause/navigation on representative mobile/desktop/Web targets;
- [ ] verify live game remains unchanged after spectator viewing;
- [ ] verify keyboard/focus/large-text/screen-reader behavior.

These results belong under qualification ID `move-replay-real-target`.

## 6. Full Replay Archive qualification

Automated/current-head checks must cover:

- [ ] `nova2048.fullReplay` versioned envelope validation;
- [ ] deterministic reconstruction of moves, Undo, continue-after-win, and timed status events;
- [ ] recorded event-time use for timed reconstruction;
- [ ] 4,096-event capture bound;
- [ ] incomplete capture policy for legacy/restored/backup sessions;
- [ ] malformed/unsupported/oversized archive rejection;
- [ ] spectator-only import isolation from trusted progress;
- [ ] English/Hindi archive/viewer coverage.

Manual real-target checks:

- [ ] large archive copy/open/manual-entry flows;
- [ ] long replay scrub/step/play/pause/speed/navigation behavior;
- [ ] 4,096-event overflow behavior without gameplay breakage;
- [ ] responsiveness on slower representative devices;
- [ ] accessibility and large-text behavior.

These results belong under qualification ID `full-replay-real-target`.

## 7. Game Backup qualification

Automated/current-head checks must cover:

- [ ] versioned backup envelope round trip;
- [ ] clipboard text size bound;
- [ ] file byte bound before UTF-8 decode;
- [ ] strict UTF-8/JSON/GameState validation;
- [ ] unsupported version/timestamp/state rejection;
- [ ] explicit restore confirmation;
- [ ] unrelated previous Undo isolation;
- [ ] imported session persists as unranked;
- [ ] imported progress cannot alter lifetime/per-mode records, achievements, streaks, or Daily history;
- [ ] imported embedded historical best score is not trusted.

Manual real-target checks:

- [ ] clipboard copy/import on representative platforms;
- [ ] `.nova2048` Save/Save As success and cancellation;
- [ ] file open and round trip into a fresh app session;
- [ ] Web download/file-input behavior;
- [ ] Android/iOS document-provider behavior;
- [ ] Windows/Linux native picker behavior;
- [ ] macOS sandboxed user-selected read/write behavior;
- [ ] oversized/non-UTF-8/malformed rejection;
- [ ] imported restart/Undo behavior;
- [ ] English/Hindi/large-text/keyboard/screen-reader flows.

These results belong under qualification ID `backup-real-target`.

## 8. Auto Play / solver qualification

Automated/current-head checks must cover:

- [ ] normal Hint remains read-only and heuristic-only;
- [ ] heuristic solver deterministic tie behavior;
- [ ] Expectimax deterministic behavior for fixed state;
- [ ] 90%/10% hypothetical 2/4 spawn modeling;
- [ ] explicit depth/node resource bounds;
- [ ] search does not consume live game RNG;
- [ ] strategy switching preserves sandbox state;
- [ ] Auto Play sandbox remains isolated from player saves/statistics/achievements/Daily history;
- [ ] deterministic benchmark fixtures remain stable.

Manual real-target checks:

- [ ] Heuristic/Expectimax switching and visible diagnostics;
- [ ] pause/resume/single-step/speed controls;
- [ ] responsiveness on slower representative devices;
- [ ] no lingering background timer after leaving the screen;
- [ ] English/Hindi, large-text, keyboard/focus and screen-reader behavior.

These results belong under qualification ID `autoplay-real-target`.

## 9. Accessibility qualification

Manual checks before stable release:

- [ ] TalkBack board/tile/control announcements.
- [ ] VoiceOver board/tile/control announcements.
- [ ] representative desktop/browser screen reader.
- [ ] row/column tile semantics.
- [ ] visible focus order and focus recovery around dialogs/navigation.
- [ ] high contrast without color-only information.
- [ ] reduced-motion behavior.
- [ ] large system text without clipped critical actions.
- [ ] English/Hindi semantics and pronunciation review.
- [ ] Statistics expandable per-mode cards under accessibility tools.
- [ ] Challenge Code, Backup, Move Replay, Full Replay Archive, and Auto Play accessibility.
- [ ] timed updates do not create disruptive repeated announcements.

These results belong under qualification ID `assistive-tech`.

## 10. Physical Android and iOS qualification

Android:

- [ ] install/run the intended release candidate on a physical Android device;
- [ ] new game, valid/invalid moves, win/continue and game over;
- [ ] background/foreground lifecycle;
- [ ] process termination and save/resume;
- [ ] Undo and restart;
- [ ] timed/move-limit/Daily flows;
- [ ] touch/orientation/responsive behavior;
- [ ] optional haptics/sound where supported.

Record genuine evidence under `android-device` and the relevant feature-specific IDs.

iOS:

- [ ] sign/provision an appropriate candidate for a physical iOS device;
- [ ] repeat gameplay/lifecycle/save/resume/Undo/restart qualification;
- [ ] verify touch/orientation/responsive behavior;
- [ ] verify file/clipboard handlers where available;
- [ ] verify optional haptics/sound where supported.

Record genuine evidence under `ios-device` and the relevant feature-specific IDs.

## 11. Responsive/input and long-session qualification

Responsive/input (`input-responsive`):

- [ ] small phone;
- [ ] large phone;
- [ ] tablet;
- [ ] landscape;
- [ ] desktop resizing;
- [ ] browser resizing;
- [ ] touch/swipe;
- [ ] Arrow/WASD;
- [ ] H/U/P/Escape/R shortcuts;
- [ ] keyboard focus and dialog focus recovery.

Long session (`long-session`):

- [ ] extended normal play;
- [ ] Daily Challenge across meaningful lifecycle transitions;
- [ ] Time Challenge;
- [ ] Move Limit;
- [ ] repeated Undo;
- [ ] target win + Continue;
- [ ] replay capture growth;
- [ ] statistics/records remain internally consistent.

## 12. Web/PWA and external-handler qualification

Source-controlled Web/PWA metadata is regression/audit protected, but real deployment behavior remains manual.

- [ ] deploy the exact release Web artifact to the intended origin;
- [ ] verify root/subpath routing for the real hosting configuration;
- [ ] verify install availability on representative compatible browsers;
- [ ] launch installed PWA and verify standalone behavior where supported;
- [ ] verify refresh/update/service-worker lifecycle behavior;
- [ ] verify browser local storage across ordinary restart/reload;
- [ ] verify expected private-browsing/eviction limitations are documented;
- [ ] verify clipboard and file-input/download handlers;
- [ ] verify GitHub/LinkedIn/Gumroad/Buy Me a Coffee/browser destinations;
- [ ] verify business/support `mailto:` handlers;
- [ ] verify bug-report destination.

Record applicable evidence under `external-handlers` plus feature-specific IDs.

## 13. Native branding qualification

- [ ] Android launcher icon presentation.
- [ ] Android splash presentation.
- [ ] iOS icon/launch presentation.
- [ ] Windows icon/product metadata presentation.
- [ ] macOS icon/launch presentation.
- [ ] Linux icon/window presentation where applicable.
- [ ] PWA installed icon/maskable presentation.
- [ ] no unintended clipping, padding, stale Flutter defaults, or wrong product name.

Record evidence under `native-branding`.

## 14. Distribution/signing/store qualification

Before stable publication:

- [ ] configure private Android production signing outside the public repository;
- [ ] build final signed Android AAB/APK as needed;
- [ ] configure Apple distribution signing/provisioning outside the repository;
- [ ] produce intended iOS archive/package through the proper Apple toolchain;
- [ ] inspect Windows/macOS/Linux package metadata where distributed;
- [ ] verify app/package identifiers and Version `2.0.12` metadata;
- [ ] verify store listing title/description/category/icons/screenshots;
- [ ] verify privacy/data-safety declarations match the offline-first implementation;
- [ ] verify clipboard/file import/export disclosures where applicable;
- [ ] verify no analytics/ads/account/cloud claims are accidentally introduced;
- [ ] verify all required policy/contact/support fields;
- [ ] confirm no credentials, certificates, private keys, keystores, tokens, or provisioning secrets are committed.

Record evidence under `distribution-metadata`.

## 15. Open repository/toolchain blockers

- [ ] **Issue #10:** only change the accepted Android AGP baseline after a controlled release-build experiment proves the previously reproduced lint/toolchain failure is resolved or after an intentional independently justified JDK/toolchain migration.
- [ ] **Issue #12:** enable actual GitHub branch protection/ruleset for `main` and the intended required checks in repository settings. CODEOWNERS/CI YAML alone do not satisfy this item.

Do not close either issue merely through documentation edits.

## 16. Final stable-promotion sequence

Only after the exact Version 2.0.12 candidate has passed the required automated and manual work:

- [ ] all 13 canonical manual records are `passed` with genuine evidence;
- [ ] every passed record has an explicit-timezone ISO-8601 timestamp;
- [ ] no release-blocking defect remains;
- [ ] latest complete CI/native evidence is recorded against the exact release commit;
- [ ] `CHANGELOG.md` is moved from Unreleased into `## [2.0.12]` only when stable metadata is intentionally finalized;
- [ ] README/docs/release notes/privacy/store metadata are final;
- [ ] `ROADMAP.md` and `what_changed.md` reflect the exact release state;
- [ ] `dart run tool/release_readiness.dart --stable --json` exits `0`;
- [ ] final signed/distribution artifacts are generated from that same commit;
- [ ] final artifacts are manually inspected;
- [ ] tag/publish only the exact qualified commit.

## Evidence discipline

Never check a manual item merely because:

- a widget/unit test exists;
- hosted compilation succeeded;
- a synthetic fixture says `passed`;
- a package checksum exists;
- a simulator/emulator partially resembles a physical-target check;
- documentation describes the intended behavior.

Evidence must describe the work actually performed on the representative environment. This is why Version 2.0.12 currently remains **0/13** manually qualified even though substantial automated/source hardening exists.
