# 2048 Nova Roadmap

## 0.9.x — Release-candidate hardening

Completed in the current release-candidate line:

- Deterministic core engine, save/resume, bounded Undo, and persisted RNG integrity.
- Ten configured game modes, including Daily Challenge and challenge limits.
- Deterministic heuristic hints with focused regression coverage.
- Isolated deterministic **Auto Play Demo** with pause/resume, single-step control, speed selection, seed reset, and strict separation from player saves/statistics/achievements/Daily history.
- Statistics, achievements, Daily history, replay-result preservation, and history repair.
- Responsive touch/keyboard UI, desktop shortcuts, themes, high contrast, reduced motion, sound/haptic toggles, and accessibility semantics.
- Android, iOS, Web, Windows, macOS, and Linux Flutter runners.
- Hosted release-build verification for Android, Linux, Windows, macOS, and unsigned iOS.
- Expanded automated engine, persistence, controller, interaction, session-integrity, accessibility, and Auto Play isolation tests.
- Open-source documentation, branding, CI, contribution/security templates, and project support/contact integration.

Remaining release qualification before `1.0.0`:

- Physical Android and iOS gameplay/lifecycle/save-resume checks.
- Representative touch, orientation, keyboard, focus, and responsive-layout checks on real target environments.
- VoiceOver, TalkBack, Narrator/browser-screen-reader checks on representative platforms.
- Long-session and real-device Daily/timed/move-limit/Undo/win-continue testing.
- Real browser/email-handler checks for external destinations.
- Native splash/icon presentation review.
- Distribution signing/provisioning and final store/package metadata review.

## 1.0.0 — First stable release

Promote the release candidate only when:

- Automated formatter, analyzer, regression tests, Web build, and configured native builds are green for the candidate state.
- Manual device/accessibility qualification above is complete.
- No known release-blocking defect remains.
- Version, changelog, release notes, privacy information, and `what_changed.md` are ready for the stable tag.

## Later — Optional expansion

These are intentionally non-blocking and must not destabilize core gameplay:

- Localization framework and Hindi translation.
- Replay visualization and export/import support.
- Optional expectimax or other advanced solver behind the already-isolated Auto Play Demo boundary, plus a benchmark suite.
- Golden/visual-regression matrices for major breakpoints and themes.
- More mode-specific records and challenge metadata.
- Richer platform-aware sound/haptic effects using only compatible/licensed resources.
- Additional desktop/PWA convenience features where they preserve the offline-first design.
