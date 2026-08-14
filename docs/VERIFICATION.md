# Release Candidate Verification

This document provides a compact index of the objective verification evidence for **2048 Nova `0.9.0+1`**. The chronological development record, including intermediate failures and their fixes, remains in [`what_changed.md`](../what_changed.md).

## Current verified code state

Final Phase 11 quality gate:

- Workflow: `CI`
- Run: `31777374553`
- Verified commit: `1ecbf0881f723af1829fda523752562660a86a98`
- Flutter: `3.47.0` stable
- Dart: `3.13.0`
- Dart formatting: **PASS** — 47 files checked, 0 changed
- Static analysis: **PASS** — no issues found
- Automated regression suite: **PASS — 81/81 tests**
- Web release build: **PASS** — `build/web` produced successfully

The verified suite includes deterministic engine rules, save migration/validation, persistence repair, Daily Challenge history/replay behavior, Undo and statistics-reset integrity, terminal-state behavior, restored challenge status, hint determinism, external-link policy, keyboard interactions, replacement guards, and accessibility semantics.

## Current verified native production-code state

The latest production-code change covered by the native matrix is:

- Commit: `b95d0a630521f896016dff733c8c4f9dc1e082e3`
- Commit message: `fix: isolate tile semantics from visual text`
- Workflow: `Platform Builds`
- Run: `31777275982`

Results:

- Android release APK: **PASS**
- Linux release: **PASS**
- Windows release: **PASS**
- macOS release: **PASS**
- iOS release with `--no-codesign`: **PASS**

The iOS build is deliberately unsigned. Signing/provisioning credentials are not stored in the repository.

## Development-log finalization

The expanded Phase 11 record was appended to `what_changed.md` by the temporary one-time documentation workflow and the temporary staging/workflow files were removed afterward.

- Appender workflow run: `31777838508` — **SUCCESS**
- Resulting documentation commit: `fafc9d86d4f0ddf890f80716dbaa9bcd613d1ffb`
- Commit message: `docs: finalize phase eleven development log`

The permanent workflow set contains only the maintained branding/platform bootstrap, CI, formatting, dependency-lock, and platform-build workflows.

## Release boundary

This evidence validates repository automation and hosted-runner builds; it is not an absolute zero-bug or universal-device-readiness claim. Promotion to `1.0.0` still requires the manual qualification in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), including representative physical-device gameplay/lifecycle checks, real assistive-technology testing, external-handler checks, native visual review, signing/provisioning, and final distribution/store metadata.

## Source of truth

Use these files together:

- [`what_changed.md`](../what_changed.md) — chronological development, defects, fixes, commits, and evidence.
- [`CHANGELOG.md`](../CHANGELOG.md) — release-facing notable changes.
- [`TESTING.md`](TESTING.md) — automated and manual test strategy.
- [`ACCESSIBILITY.md`](ACCESSIBILITY.md) — implemented accessibility foundations and manual qualification.
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) — automated gate and remaining manual release tasks.
- [`ROADMAP.md`](../ROADMAP.md) — stable-release boundary and non-blocking later work.
