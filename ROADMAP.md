# 2048 Nova Roadmap

## 0.9.x — Release-candidate hardening

Completed in the current release-candidate line:

- Deterministic core engine, save/resume, bounded Undo, and persisted RNG integrity.
- Ten configured game modes, including Daily Challenge and challenge limits.
- Deterministic heuristic hints with focused regression coverage.
- Isolated deterministic **Auto Play Demo** with pause/resume, single-step control, speed selection, seed reset, and strict separation from player saves/statistics/achievements/Daily history.
- Read-only **Move Replay** built from validated bounded Undo snapshots, with timeline scrubbing, first/previous/next/latest navigation, play/pause, speed selection, defensive copies, and no live-game mutation path.
- Versioned **Game Backup** for copying/restoring one current game through the clipboard with strict input validation, explicit replacement confirmation, Undo isolation, and persistent unranked-import policy.
- Imported-backup trust isolation so portable/editable data cannot inflate lifetime statistics, achievements, streaks, Daily history, or historical best-score records.
- Statistics, achievements, Daily history, best-result preservation, and corruption/self-repair behavior.
- Responsive touch/keyboard UI, desktop shortcuts, themes, high contrast, reduced motion, sound/haptic toggles, and accessibility semantics.
- Android, iOS, Web, Windows, macOS, and Linux Flutter runners.
- Hosted release-build verification for Android, Linux, Windows, macOS, and unsigned iOS.
- Expanded automated engine, persistence, controller, interaction, session-integrity, accessibility, Auto Play isolation, Replay timeline, portable-backup, clipboard-flow, and imported-ranking tests.
- Complete user/technical/development/release documentation set, branding, CI, contribution/security templates, and project support/contact integration.

Remaining release qualification before `1.0.0`:

- Physical Android and iOS gameplay/lifecycle/save-resume checks.
- Representative touch, orientation, keyboard, focus, and responsive-layout checks on real target environments.
- VoiceOver, TalkBack, Narrator/browser-screen-reader checks on representative platforms.
- Long-session and real-device Daily/timed/move-limit/Undo/win-continue testing.
- Real-platform Move Replay scrub/play/pause/navigation-away/accessibility checks.
- Real-platform Game Backup copy/import/cancel/restore/restart/Undo checks using actual clipboard handlers.
- Real browser/email-handler checks for external destinations.
- Native splash/icon presentation review.
- Distribution signing/provisioning and final store/package metadata review.

## 1.0.0 — First stable release

Promote the release candidate only when:

- automated formatter, analyzer, regression tests, Web build, and configured native builds are green for the candidate state;
- manual device/accessibility qualification above is complete;
- backup/restore and external platform-handler checks are complete on representative targets;
- no known release-blocking defect remains;
- version, changelog, release notes, privacy information, complete documentation, and `what_changed.md` are ready for the stable tag.

## Later — Optional expansion

These are intentionally non-blocking and must not destabilize core gameplay:

- Localization framework and Hindi translation.
- A separate full-session replay export/import format beyond the current bounded Undo-backed viewer.
- Optional file-based backup import/export in addition to the implemented clipboard backup, with the same strict validation/unranked policy.
- Shareable seeded challenge codes without accounts or cloud synchronization.
- Optional expectimax or another advanced solver behind the already-isolated Auto Play Demo boundary, plus a benchmark suite.
- Golden/visual-regression matrices for major breakpoints and themes.
- More mode-specific records and challenge metadata.
- Richer platform-aware sound/haptic effects using only compatible/licensed resources.
- Additional desktop/PWA convenience features where they preserve the offline-first design.

## Design guardrails for future features

Future expansion should preserve these verified boundaries unless a deliberate redesign is documented and tested:

- deterministic engine remains independent of UI;
- normal Hint remains read-only;
- Auto Play remains isolated from trusted player state;
- Replay remains spectator-only;
- portable/editable import remains unranked unless a real trust/authentication system is introduced;
- local persistence remains validated and corruption-safe;
- growing histories remain bounded;
- external links remain explicit and scheme-validated;
- no analytics/ads/accounts/cloud dependency is added silently;
- automated verification does not replace real-device and assistive-technology release qualification.
