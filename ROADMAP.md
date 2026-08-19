# 2048 Nova Completion Roadmap

## 2.0.12 — Feature-complete source target

**Source status: feature-complete for the declared Version 2.0.12 product scope.**

The active source-development roadmap is complete. Remaining items below are release/distribution qualification that require genuine representative environments; they are not missing application features.

Completed source scope:

- Deterministic core 2048 engine with persisted RNG integrity.
- Save/resume, validated persistence, corruption recovery, and bounded deterministic Undo.
- Ten configured modes: Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, Daily Challenge, and Zen.
- Date-seeded offline Daily Challenge with protected history semantics.
- Offline shareable seeded **Challenge Codes** with a versioned `NOVA1` format, deterministic config/seed round trip, checksum validation, strict input bounds, decoded preview, replacement protection, clipboard/manual entry, and local high-contrast QR rendering of the exact code text.
- Daily Challenge isolation from arbitrary Challenge Code seeds.
- Deterministic read-only Hint behavior.
- Isolated deterministic **Auto Play Demo** with Heuristic and bounded Expectimax strategies, pause/resume, single step, speed selection, seed reset, search-node diagnostics, deterministic benchmark tooling, and strict isolation from trusted player state.
- Read-only **Move Replay** built from validated bounded Undo snapshots with timeline scrub, navigation, playback, speed control, defensive copies, and no live-game mutation path.
- Portable spectator-only **Full Replay Archives** with a versioned `nova2048.fullReplay` envelope, deterministic move/Undo/win-continuation/timed-status reconstruction, complete-session eligibility rules, a 4,096-event safety bound, clipboard/manual import, English/Hindi UI, and no trusted-progress import path.
- Versioned **Game Backup** through clipboard and explicit user-selected `.nova2048` / `.json` files with byte/text bounds, strict validation, replacement confirmation, Undo isolation, and persistent unranked-import policy.
- Imported-backup trust isolation from lifetime statistics, achievements, streaks, Daily history, global best records, and per-mode records.
- Local statistics, achievements, Daily history, global best-result preservation, and trusted per-mode records with board/target metadata.
- Responsive touch/keyboard UI, desktop shortcuts, themes, seven palettes, high contrast, reduced motion, optional sound/haptics, accessibility semantics, and offline English/Hindi localization with persisted System/English/हिन्दी selection.
- Android, iOS, Web/PWA, Windows, macOS, and Linux Flutter runners.
- Web/PWA install metadata with stable relative identity/start/scope, source language/direction, categories, mobile/Apple install metadata, regular/maskable 192/512 icons, and source regressions.
- Android release APK and Google Play AAB build paths, SHA-256 sidecars, artifact packaging, and a focused regression guard that fails if either distribution output disappears.
- Linux, Windows, macOS, and unsigned-iOS release-build paths with checksummed hosted qualification artifacts.
- Complete user, technical, architecture, engine, mode, data, privacy, accessibility, localization, security, support, dependency, CI/CD, build, release, troubleshooting, contribution, and maintenance documentation.
- Evidence-backed release qualification infrastructure with `docs/release_qualification.json`, `tool/release_readiness.dart`, the guarded evidence recorder, and the read-only status reporter.
- Permanent CI for dependency resolution, metadata drift, formatter, analyzer, tests, candidate release gate, qualification status, repository audit, deterministic solver smoke, and Web release build.
- Repository integrity audit for required files, release/version consistency, Web/PWA metadata, temporary-helper cleanup, and local Markdown links.
- Dependabot, pull-request dependency review, CODEOWNERS, security/support templates, issue/PR templates, and pinned reviewed GitHub Action revisions.
- Version 2.0.12 synchronization across package/build metadata (`2.0.12+2012`), in-app marketing version (`2.0.12`), Windows fallback resources, qualification candidate metadata, release tooling, source audits, and regression fixtures.
- Final source-completion audit in `docs/FINAL_2_0_12_SOURCE_AUDIT.md`.
- Post-completion maintenance policy in `docs/MAINTENANCE_POLICY.md`.

The repository-owned formatter automation produced commit `a2372253f5eb4dde16339e6c913e8581408311fc` after the 2.0.12 migration, proving the maintained Dart formatter successfully parsed and normalized `lib/`, `test/`, and `tool/`. A formatter run is not substituted for a complete analyzer/test/native result.

The latest previously accepted complete CI/native evidence remains the historical Version 1.5 baseline recorded in `docs/VERIFICATION.md` until a complete maintained Version 2.0.12 workflow result is actually observed and recorded.

## Remaining release qualification before `2.0.12`

These are **external qualification activities**, not unfinished source features:

- Physical Android and iOS gameplay/lifecycle/save-resume checks.
- Representative touch, orientation, keyboard, focus, and responsive-layout checks on real target environments.
- VoiceOver, TalkBack, Narrator/browser-screen-reader checks on representative platforms, including Hindi semantics/pronunciation and large-text behavior.
- Long-session Daily/timed/move-limit/Undo/win-continue testing.
- Representative Auto Play Heuristic/Expectimax strategy switching, pause behavior, performance/responsiveness, localization, and accessibility checks on real targets.
- Real-platform Challenge Code QR/display/copy/paste/manual-entry/validation/replacement/determinism/accessibility checks using actual screens, external scanner apps where applicable, and real clipboard/browser handlers.
- Real-platform Move Replay scrub/play/pause/navigation-away/accessibility checks.
- Real-platform Full Replay Archive import/playback/4,096-event-boundary/long-replay/accessibility checks.
- Real-platform Game Backup clipboard and file Save/Open/cancel/round-trip/error/restore/restart/Undo checks using actual browser/native document handlers.
- Real browser/PWA install/lifecycle/storage plus browser/email-handler checks.
- Native splash/icon presentation review.
- Distribution signing/provisioning, privacy/data-safety declarations, package metadata, and store metadata review.

Each item has a stable machine-readable ID in `docs/release_qualification.json`. Use:

```bash
dart run tool/release_qualification_status.dart --pending-only
```

and record evidence only after the corresponding real-world check was genuinely performed.

Hosted compilation, source inspection, widget tests, generated artifacts, or documentation review are not substitutes for physical/accessibility/signing/store evidence.

## 2.0.12 — Qualified stable distribution target

Promote the source-complete candidate to a qualified stable distribution only when:

- formatter, analyzer, full regression tests, release-candidate metadata gate, qualification-status validation, repository audit, solver smoke, Web release build, and configured native builds are green for the exact candidate commit;
- all required manual evidence entries are genuinely passed with verifiable evidence and explicit-timezone timestamps;
- Challenge Code, replay, backup/restore, PWA, external-handler, branding, signing/provisioning, and distribution checks are complete on representative targets;
- no known release-blocking defect remains;
- changelog, release notes, privacy information, store metadata, complete documentation, and `what_changed.md` are ready for the exact release commit;
- `dart run tool/release_readiness.dart --stable` exits successfully on that exact commit.

## No active post-2.0.12 feature backlog

Version 2.0.12 does **not** carry a hidden “later” feature list.

The following are deliberate non-goals unless a future release explicitly adopts them:

- additional languages beyond English/Hindi;
- in-app QR scanning/camera permission or OS share-sheet integration;
- cloud accounts, cloud save, telemetry, advertising, remote AI, online multiplayer, online leaderboards, or anti-cheat services;
- deeper/adaptive solver variants beyond the implemented deterministic Heuristic/bounded-Expectimax sandbox;
- extra visual-effects/audio systems beyond the maintained lightweight options;
- additional statistics that cannot be reconstructed truthfully from trusted local state;
- extra desktop/PWA convenience integrations that would expand privacy/platform maintenance without a concrete need.

A proposal for any non-goal starts a **new release scope**. It is not unfinished Version 2.0.12 work.

## Maintenance after source completion

Normal post-completion work is limited to:

- reproducible bug fixes;
- security fixes;
- accessibility/localization corrections for implemented behavior;
- dependency/toolchain/platform maintenance after compatibility review;
- documentation/CI maintenance;
- genuine manual-qualification evidence updates;
- deliberately scoped future releases.

See `docs/MAINTENANCE_POLICY.md`.

## Design guardrails

Any future release must preserve these boundaries unless an intentional redesign is documented and regression-tested:

- deterministic engine remains independent of UI;
- Challenge Codes remain configuration-only unless a separately versioned protocol is introduced; checksum is never authentication;
- Daily seed/history remains protected from arbitrary portable-code injection;
- normal Hint remains read-only;
- Auto Play remains isolated from trusted player state;
- Move Replay and imported Full Replay Archives remain spectator-only;
- portable replay text is structural/deterministic data, not proof of authorship;
- portable/editable progress remains unranked unless a real authenticated trust system is introduced;
- local aggregate/per-mode records accept only trusted local-session progress;
- persistence remains validated, corruption-safe, and bounded;
- external links remain explicit and scheme-validated;
- analytics, ads, accounts, cloud dependencies, camera permissions, or remote services are never added silently;
- automated verification never substitutes for real-device and assistive-technology release qualification;
- stable-release automation fails closed when required manual evidence is missing, malformed, structurally stale, or inconsistent with the package version.
