# Release Candidate Verification

This document provides a compact index of the objective verification evidence for **2048 Nova `0.9.0+1`**. The chronological development record, including intermediate failures and their fixes, remains in [`what_changed.md`](../what_changed.md).

## Current verified code state

Latest completed Phase 12 Auto Play quality gate:

- Workflow: `CI`
- Run: `31778558429`
- Verified commit: `1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6`
- Flutter: `3.47.0` stable
- Dart: `3.13.0`
- Dart formatting: **PASS** — 51 files checked, 0 changed
- Static analysis: **PASS** — no issues found
- Automated regression suite: **PASS — 86/86 tests**
- Web release build: **PASS** — `build/web` produced successfully
- Web WASM dry run: **PASS**

The verified suite includes deterministic engine rules, save migration/validation, persistence repair, Daily Challenge history/replay behavior, Undo and statistics-reset integrity, terminal-state behavior, restored challenge status, hint determinism, external-link policy, keyboard interactions, replacement guards, accessibility semantics, and isolated Auto Play determinism/control/player-data separation.

The Web build continues to emit a non-fatal informational CupertinoIcons font lookup warning even though the project does not directly reference `CupertinoIcons`; the release Web output is still produced successfully.

## Current verified native production-code state

The Auto Play production code is covered by:

- Workflow: `Platform Builds`
- Run: `31778424208`
- Verified commit: `a1cc17836834750c542c69ffdf3c5e582d4e43ab`

Results:

- Android release APK: **PASS**
- Linux release: **PASS**
- Windows release: **PASS**
- macOS release: **PASS**
- iOS release with `--no-codesign`: **PASS**

That commit contains the Auto Play domain/session, route, UI, Home entry, guide integration, and all preceding production-code changes. Later commits in the Phase 12 sequence changed tests, documentation, or formatting only.

The iOS build is deliberately unsigned. Signing/provisioning credentials are not stored in the repository.

## Auto Play / AI Demonstration verification boundary

The optional Auto Play feature required by the project specification is implemented as a deterministic local heuristic demonstration rather than a cloud/model-backed AI service.

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

## Historical Phase 11 evidence

The pre-Auto-Play Phase 11 quality gate remains useful historical evidence:

- CI run `31777374553`
- commit `1ecbf0881f723af1829fda523752562660a86a98`
- formatter **PASS** — 47 files, 0 changed
- analyzer **PASS**
- **81/81 tests PASS**
- Web release build **PASS**

The Phase 11 native matrix was run `31777275982` on production-code commit `b95d0a630521f896016dff733c8c4f9dc1e082e3`, with Android/Linux/Windows/macOS/unsigned-iOS all successful.

## Development-log finalization

The expanded Phase 11 record was appended to `what_changed.md` by the temporary one-time documentation workflow and its temporary files were removed afterward.

- Phase 11 appender workflow run: `31777838508` — **SUCCESS**
- Resulting documentation commit: `fafc9d86d4f0ddf890f80716dbaa9bcd613d1ffb`

Phase 12 evidence is recorded chronologically in `what_changed.md` after Auto Play finalization.

The permanent workflow set remains limited to the maintained branding/platform bootstrap, CI, formatting, dependency-lock, and platform-build workflows.

## Release boundary

This evidence validates repository automation and hosted-runner builds; it is not an absolute zero-bug or universal-device-readiness claim. Promotion to `1.0.0` still requires the manual qualification in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), including representative physical-device gameplay/lifecycle checks, real assistive-technology testing, Auto Play timer/control behavior on representative real platforms, external-handler checks, native visual review, signing/provisioning, and final distribution/store metadata.

## Source of truth

Use these files together:

- [`what_changed.md`](../what_changed.md) — chronological development, defects, fixes, commits, and evidence.
- [`CHANGELOG.md`](../CHANGELOG.md) — release-facing notable changes.
- [`TESTING.md`](TESTING.md) — automated and manual test strategy.
- [`HINT_SOLVER.md`](HINT_SOLVER.md) — hint heuristic and isolated Auto Play architecture.
- [`ACCESSIBILITY.md`](ACCESSIBILITY.md) — implemented accessibility foundations and manual qualification.
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) — automated gate and remaining manual release tasks.
- [`ROADMAP.md`](../ROADMAP.md) — stable-release boundary and non-blocking later work.
