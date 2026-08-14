# Release Candidate Verification

This document provides a compact index of the objective verification evidence for **2048 Nova `0.9.0+1`**. The chronological development record, including intermediate failures and their fixes, remains in [`what_changed.md`](../what_changed.md).

## Current verified code state

Latest completed Phase 13 Move Replay quality gate:

- Workflow: `CI`
- Run: `31779838751`
- Verified commit: `278ba039d0b7b59ce54c72c5ed0fcd0401ba537a`
- Flutter: `3.47.0` stable
- Dart: `3.13.0`
- Dart formatting: **PASS** — 55 files checked, 0 changed
- Static analysis: **PASS** — no issues found
- Automated regression suite: **PASS — 92/92 tests**
- Web release build: **PASS** — `build/web` produced successfully
- Web WASM dry run: **PASS**

The verified suite includes deterministic engine rules, save migration/validation, persistence repair, Daily Challenge history/replay behavior, Undo and statistics-reset integrity, terminal-state behavior, restored challenge status, hint determinism, external-link policy, keyboard interactions, replacement guards, accessibility semantics, Auto Play determinism/isolation, and Move Replay filtering/immutability/playback behavior.

The Web build continues to emit a non-fatal informational CupertinoIcons font lookup warning even though the project does not directly reference `CupertinoIcons`; the release Web output is still produced successfully.

## Current verified native production-code state

The complete Replay production code and in-app guide integration are covered by:

- Workflow: `Platform Builds`
- Run: `31779566057`
- Verified commit: `4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd`

Results:

- Android release APK: **PASS**
- Linux release: **PASS**
- Windows release: **PASS**
- macOS release: **PASS**
- iOS release with `--no-codesign`: **PASS**

That native commit contains the Replay timeline domain code, Replay screen, route, Home entry, guide integration, Auto Play production code, and all preceding core production changes. Later Phase 13 commits changed tests or Markdown documentation only.

The iOS build is deliberately unsigned. Signing/provisioning credentials are not stored in the repository.

## Move Replay verification boundary

The optional Replay / move-history feature is implemented as a read-only spectator view backed by the existing validated bounded Undo history rather than a second persistence format.

Automated verification covers:

- current-session filtering using start time and complete game configuration identity;
- rejection of future/impossible move, merge, or score frames;
- chronological ordering by move count;
- duplicate move-number collapse;
- authoritative current game as the final frame;
- defensive copied board/state data;
- an unmodifiable returned timeline;
- first/next/latest UI navigation;
- timed replay playback;
- Pause stopping later automatic frame changes;
- safe empty state when no current game exists;
- live player board, score, move count, and RNG remaining unchanged while replay frames are viewed.

Replay adds no new persistence key, network service, account data, or telemetry. Because Undo history is bounded, a long game's replay may begin at the earliest retained snapshot rather than move zero; the UI explicitly discloses this limitation.

### Transparent intermediate Replay test failure

CI run `31779369661` passed formatting and static analysis but recorded **90 passed / 2 failed** in the test step. The two Replay widget tests attempted to tap timeline controls that were below Flutter's default 800×600 widget-test viewport. The production Replay screen was already scrollable; the test harness had incorrectly assumed the controls were initially visible.

Commit `501b2a512c2f185461129f2e294504e43e883d59` (`test: scroll replay controls before widget taps`) scrolled the controls into view before tapping. The final 92-test gate above then passed. This failure is retained as evidence rather than hidden.

## Auto Play / AI Demonstration verification boundary

The optional Auto Play feature is implemented as a deterministic local heuristic demonstration rather than a cloud/model-backed AI service.

Automated verification covers:

- fixed-seed reset reproducibility;
- matching-seed autoplay sequence reproducibility;
- single-step behavior;
- Auto Play start/pause;
- speed selection;
- stopped timer behavior after Pause;
- demo metrics that are explicitly labeled as demo values;
- no creation/replacement of the player `AppController.game`;
- no changes to player games-played, total-moves, or lifetime-best statistics during demo stepping/reset;
- no persistence key, network service, model download, achievement write, or Daily-history write path in the demo architecture.

This verifies the implemented heuristic Auto Play boundary. It does not claim optimal 2048 solving, machine-learning behavior, or an expectimax guarantee.

## Historical quality progression

Phase 12 Auto Play quality gate:

- CI run `31778558429`
- commit `1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6`
- formatter **PASS** — 51 files, 0 changed
- analyzer **PASS**
- **86/86 tests PASS**
- Web release build **PASS**.

Phase 11 pre-Auto-Play quality gate:

- CI run `31777374553`
- commit `1ecbf0881f723af1829fda523752562660a86a98`
- formatter **PASS** — 47 files, 0 changed
- analyzer **PASS**
- **81/81 tests PASS**
- Web release build **PASS**.

## Development-log finalization

The expanded Phase 11 record was appended to `what_changed.md` by temporary one-time documentation workflow run `31777838508`, producing commit `fafc9d86d4f0ddf890f80716dbaa9bcd613d1ffb` and removing its temporary files.

Phase 12 was appended by workflow run `31778939887`, producing commit `1e4bba007c4e7f43607d46e7cbc152c65840d0e9` and removing its temporary files.

Phase 13 evidence is appended to `what_changed.md` after this verification manifest is updated.

The permanent workflow set remains limited to the maintained branding/platform bootstrap, CI, formatting, dependency-lock, and platform-build workflows.

## Release boundary

This evidence validates repository automation and hosted-runner builds; it is not an absolute zero-bug or universal-device-readiness claim. Promotion to `1.0.0` still requires the manual qualification in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), including representative physical-device gameplay/lifecycle checks, real assistive-technology testing, Replay and Auto Play timer/control behavior on representative real platforms, external-handler checks, native visual review, signing/provisioning, and final distribution/store metadata.

## Source of truth

Use these files together:

- [`what_changed.md`](../what_changed.md) — chronological development, defects, fixes, commits, and evidence.
- [`CHANGELOG.md`](../CHANGELOG.md) — release-facing notable changes.
- [`TESTING.md`](TESTING.md) — automated and manual test strategy.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — core, persistence, Replay, and Auto Play boundaries.
- [`HINT_SOLVER.md`](HINT_SOLVER.md) — hint heuristic and isolated Auto Play architecture.
- [`ACCESSIBILITY.md`](ACCESSIBILITY.md) — implemented accessibility foundations and manual qualification.
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) — automated gate and remaining manual release tasks.
- [`ROADMAP.md`](../ROADMAP.md) — stable-release boundary and non-blocking later work.
