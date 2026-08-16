# 2048 Nova Roadmap

## 0.9.x — Release-candidate hardening

Completed in the current release-candidate line:

- Deterministic core engine, save/resume, bounded Undo, and persisted RNG integrity.
- Ten configured game modes, including Daily Challenge and challenge limits.
- Offline shareable seeded **Challenge Codes** with a versioned `NOVA1` format, deterministic config/seed round trip, corruption checksum, strict input validation, manual/clipboard entry, decoded preview, replacement protection, local high-contrast QR rendering of the exact code text, and no account/cloud/camera requirement.
- Daily Challenge isolation from arbitrary Challenge Codes so date-derived seed/history semantics remain separate.
- Deterministic heuristic hints with focused regression coverage.
- Isolated deterministic **Auto Play Demo** with pause/resume, single-step control, speed selection, seed reset, selectable Heuristic/bounded-Expectimax strategies, visible search-node diagnostics, a deterministic benchmark suite/CLI, and strict separation from player saves/statistics/achievements/Daily history.
- Read-only **Move Replay** built from validated bounded Undo snapshots, with timeline scrubbing, first/previous/next/latest navigation, play/pause, speed selection, defensive copies, and no live-game mutation path.
- Portable spectator-only **Full Replay Archives** with a versioned `nova2048.fullReplay` JSON envelope, deterministic move/Undo/win-continuation/timed-status event reconstruction, complete-session eligibility checks, a 4,096-event safety bound, clipboard/manual import, English/Hindi UI, and strict isolation from live/trusted player progress.
- Versioned **Game Backup** for copying/restoring one current game through the clipboard or explicit user-selected `.nova2048` / `.json` files, with pre-decode file-size bounds, strict shared validation, explicit replacement confirmation, Undo isolation, and persistent unranked-import policy.
- Imported-backup trust isolation so portable/editable data cannot inflate lifetime statistics, achievements, streaks, Daily history, global best-score records, or per-mode records.
- Statistics, achievements, Daily history, global best-result preservation, and corruption/self-repair behavior.
- Trusted local **per-mode records** for best score and highest tile, including best-score board/target metadata, backward-compatible persistence, active-session reset baselines, localized Statistics presentation, and imported-backup isolation.
- Responsive touch/keyboard UI, desktop shortcuts, themes, high contrast, reduced motion, sound/haptic toggles, accessibility semantics, and offline English/Hindi localization with persisted System/English/हिन्दी language selection.
- Android, iOS, Web, Windows, macOS, and Linux Flutter runners.
- Hosted release-build verification for Android, Linux, Windows, macOS, and unsigned iOS.
- Expanded automated engine, persistence, controller, interaction, session-integrity, accessibility, Challenge Code, Auto Play isolation, bounded Move Replay, full-session replay protocol/capture/storage/spectator UI, portable-backup, clipboard-flow, imported-ranking, per-mode-record persistence/trust/reset, and localized UI tests.
- Complete user/technical/development/release documentation set, branding, CI, contribution/security templates, and project support/contact integration.
- Evidence-backed release qualification infrastructure: `docs/release_qualification.json`, `docs/RELEASE_QUALIFICATION.md`, and `tool/release_readiness.dart` keep normal release-candidate CI usable while making strict stable-release mode fail until every required real-world qualification item has recorded passed evidence and release metadata is actually `1.0.0`.
- Permanent CI now formats `tool/` together with application/tests, runs the release-candidate readiness gate, and smoke-runs the deterministic solver benchmark in addition to the existing analyzer/tests/Web release build.
- Release-readiness CLI regression fixtures now exercise both opening and fail-closed branches end to end, including a fully qualified synthetic stable fixture plus malformed/incomplete evidence rejection; maintained CI is 200/200 tests.

Remaining release qualification before `1.0.0`:

- Physical Android and iOS gameplay/lifecycle/save-resume checks.
- Representative touch, orientation, keyboard, focus, and responsive-layout checks on real target environments.
- VoiceOver, TalkBack, Narrator/browser-screen-reader checks on representative platforms, including Hindi semantics, pronunciation, large-text wrapping, language switching, expanded per-mode Statistics cards, and Full Replay Archive controls/status text.
- Long-session and real-device Daily/timed/move-limit/Undo/win-continue testing.
- Representative Auto Play Heuristic/Expectimax strategy switching, pause behavior, performance/responsiveness, localization, and accessibility checks on real targets.
- Real-platform Challenge Code generate/QR-display/device-to-device scan/copy/paste/manual-entry/validation/replacement/determinism/accessibility checks using actual screens, external camera/scanner apps, and clipboard/browser handlers.
- Real-platform Move Replay scrub/play/pause/navigation-away/accessibility checks.
- Real-platform Full Replay Archive copy/open/manual-entry/import/scrub/play/pause/navigation-away/4,096-event-boundary/accessibility checks, including long replay responsiveness on slower devices.
- Real-platform Game Backup clipboard copy/import plus file Save/Open/cancel/round-trip/oversize/non-UTF-8/restore/restart/Undo checks using actual clipboard, browser download/file-input, native picker, document-provider, and macOS sandbox handlers.
- Real browser/email-handler checks for external destinations.
- Native splash/icon presentation review.
- Distribution signing/provisioning and final store/package metadata review.

Each item above has a stable machine-readable ID in `docs/release_qualification.json`. A maintainer must record genuine evidence there rather than treating hosted compilation or automated widget tests as a substitute for physical qualification.

## 1.0.0 — First stable release

Promote the release candidate only when:

- automated formatter, analyzer, regression tests, release-candidate metadata gate, deterministic solver smoke benchmark, Web build, and configured native builds are green for the candidate state;
- manual device/accessibility qualification above is complete and every required manifest entry contains passed evidence plus a valid timestamp;
- Challenge Code, replay archive, backup/restore, and external platform-handler checks are complete on representative targets;
- no known release-blocking defect remains;
- version, changelog, release notes, privacy information, complete documentation, and `what_changed.md` are ready for the stable tag;
- `dart run tool/release_readiness.dart --stable` exits successfully on the exact commit intended for tagging.

## Later — Optional expansion

These are intentionally non-blocking and must not destabilize core gameplay:

- Additional languages beyond the implemented English/Hindi framework, only with complete translation, layout, persistence, and accessibility qualification.
- Optional **in-app QR scanning** or OS share-sheet convenience for the already-implemented Challenge Code text/QR format, only if camera permissions, cross-platform maintenance, privacy, and accessibility costs are justified. Local QR rendering itself is already implemented.
- Optional deeper/adaptive or alternative solver strategies only if they preserve the existing Auto Play sandbox, deterministic benchmark coverage, explicit resource limits, and normal Hint behavior.
- Golden/visual-regression matrices for major breakpoints and themes.
- Additional trustworthy mode-specific metadata beyond the implemented best-score/highest-tile records, only when it can be migrated and measured without inventing historical facts.
- Richer platform-aware sound/haptic effects using only compatible/licensed resources.
- Additional desktop/PWA convenience features where they preserve the offline-first design.

## Design guardrails for future features

Future expansion should preserve these verified boundaries unless a deliberate redesign is documented and tested:

- deterministic engine remains independent of UI;
- Challenge Codes remain configuration-only unless a separately versioned protocol is designed; checksum must not be described as authentication;
- Daily Challenge seed/history remains protected from arbitrary portable-code injection unless intentionally redesigned;
- normal Hint remains read-only;
- Auto Play remains isolated from trusted player state;
- both Move Replay and imported Full Replay Archives remain spectator-only;
- portable replay text is structurally/deterministically validated but is not proof of authorship and never becomes trusted progress;
- portable/editable progress import remains unranked unless a real trust/authentication system is introduced;
- local aggregate and per-mode records accept only trusted local-session progress;
- local persistence remains validated and corruption-safe;
- growing histories remain bounded, including full replay capture;
- external links remain explicit and scheme-validated;
- no analytics/ads/accounts/cloud dependency is added silently;
- automated verification does not replace real-device and assistive-technology release qualification;
- stable-release automation must fail closed when required manual evidence is missing, malformed, stale in structure, or inconsistent with the package version.
