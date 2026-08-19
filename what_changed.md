# 2048 Nova — Detailed Change and Verification Continuity

This file is the current continuity index for active development. The complete historical log through Phase 30 is preserved verbatim in [`what_changed_archive_phase_00_30.md`](what_changed_archive_phase_00_30.md).

- **Current phase:** Phase 31 — read-only release-qualification status reporting plus Web/PWA metadata hardening implemented, regression-tested in source, CI-wired where applicable, integrity-audited, and documented; the latest previously accepted full CI/native evidence remains the Phase 29 Version 1.5 baseline until a newer maintained workflow result is explicitly recorded; the stable qualification boundary remains 0/13 and GitHub issues #10 and #12 remain explicit.
- **Package candidate:** `1.5.0+15`.
- **Runtime marketing version:** `1.5.0`.
- **Latest previously accepted full CI/native evidence:** CI run `32018055661` with **235/235 tests** and **106 files formatter-clean**; native matrix run `32015893841`.
- **Stable qualification boundary remains 0/13:** no physical-device, assistive-technology, signing/provisioning, external-handler, branding, browser-install, or store evidence has been fabricated or inferred from hosted automation.

## Historical continuity

The original chronological implementation log through Phase 30 is preserved without rewriting at:

- [`what_changed_archive_phase_00_30.md`](what_changed_archive_phase_00_30.md)

That archive remains the detailed source for Phases 0–30, intermediate failures/fixes, previous CI/native evidence, release hardening, feature implementation history, and the guarded qualification recorder introduced in Phase 30.

# Phase 31 — Read-only release qualification status reporting

Date: **2026-08-19**

## Why this phase was selected

The Version 1.5 source tree already contains the major gameplay, replay, backup, Challenge Code, localization, solver, platform, build, and release-readiness work. The remaining stable-release blockers are the 13 real-world checks in `docs/release_qualification.json`. Those checks require representative physical devices, assistive technology, native/external handlers, signing/provisioning, or store review and therefore cannot be truthfully manufactured by hosted automation.

Phase 31 improves the maintainer workflow around that boundary without weakening it. It adds a deterministic read-only status reporter, focused process-level tests, permanent CI reporting, repository-integrity enforcement, and documentation that makes the remaining checks easier to inspect while preserving the fail-closed stable gate.

## Qualification status reporter

Added `tool/release_qualification_status.dart` with:

```text
--json
--pending-only
--fail-if-incomplete
--root=<path>
--help / -h
```

The reporter validates:

- qualification schema version `1`;
- non-empty candidate version;
- exactly the canonical 13 manual-check IDs;
- no duplicate or unknown IDs;
- non-empty titles;
- statuses limited to `pending`, `passed`, or `blocked`;
- no stale evidence/timestamp on pending checks;
- non-empty evidence for passed/blocked checks;
- ISO-8601 `updatedAt` values with explicit `Z` or numeric UTC offsets for passed/blocked checks.

Normal reporting exits successfully for a structurally valid manifest even while qualification is incomplete. `--fail-if-incomplete` uses exit code `3` when a caller intentionally wants incomplete qualification to fail. Invalid arguments or malformed evidence use exit code `64`.

The reporter is read-only. It never edits `docs/release_qualification.json`, changes a check status, or generates manual evidence.

## Aggregate filtering correction

The first implementation filtered the report object for `--pending-only`, which could have made filtered aggregate counts describe only visible detail rows. This was corrected before adoption: filtering now affects only the detail list while `total`, `passed`, `pending`, `blocked`, and `complete` always describe the complete canonical 13-check manifest.

Regression coverage protects this invariant.

## Regression coverage

`test/release_qualification_status_cli_test.dart` now exercises process-level behavior for:

1. human-readable pending summaries;
2. JSON aggregate counts;
3. passed/pending/blocked mixtures;
4. pending-only detail filtering with unchanged full totals;
5. distinct incomplete exit code `3`;
6. fully passed synthetic fixtures;
7. missing canonical IDs;
8. unknown IDs even when the check count remains 13;
9. passed entries without evidence;
10. blocked entries without evidence;
11. passed timestamps without explicit timezone offsets;
12. unknown arguments;
13. duplicate `--root` arguments.

Synthetic fixtures verify the CLI only. They are not release evidence for 2048 Nova.

## Repository audit hardening

`tool/repository_audit.dart` now treats the Phase 31 reporting layer as part of the permanent release contract. It requires:

- `docs/QUALIFICATION_STATUS.md`;
- `docs/PHASE_31_VERIFICATION.md`;
- `tool/release_qualification_status.dart`.

It also requires the continuity log to identify Phase 31 while preserving the literal `stable qualification boundary remains 0/13` boundary. Focused audit regressions reject leftover Phase 31 one-shot maintenance helpers.

## Permanent CI behavior

`.github/workflows/ci.yml` now runs:

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

This validates and surfaces the live incomplete set in CI logs without mutating evidence. CI separately exercises `tool/release_readiness.dart --stable` as the fail-closed stable-promotion boundary.

## Documentation completed

Phase 31 documentation includes:

- [`docs/QUALIFICATION_STATUS.md`](docs/QUALIFICATION_STATUS.md) — CLI contract, JSON shape, exit codes, validation rules, workflow, and trust boundary;
- [`docs/PHASE_31_VERIFICATION.md`](docs/PHASE_31_VERIFICATION.md) — implementation/verification record;
- [`docs/RELEASE_QUALIFICATION.md`](docs/RELEASE_QUALIFICATION.md) — read-only status workflow integrated with the qualification process;
- [`docs/REPOSITORY_AUDIT.md`](docs/REPOSITORY_AUDIT.md) — Phase 31 integrity requirements;
- [`docs/README.md`](docs/README.md) — documentation index/source-of-truth mapping;
- [`ROADMAP.md`](ROADMAP.md) — current Version 1.5 release-hardened state;
- [`tool/README.md`](tool/README.md) — maintainer command index.

## Phase 31 commit sequence

The work was intentionally split into small meaningful commits, including:

```text
2f176648  feat: add release qualification status reporter
648a7f75  fix: preserve qualification summary when filtering
843d4ec5  fix: enforce canonical qualification checklist
2f11942f  test: cover release qualification status reporter
01ed738e  ci: report manual qualification status
2fbf6e9f  docs: document qualification status reporter
6005018e  docs: add qualification status reference
db86c5d1  docs: record qualification status tooling in roadmap
e35d3965  docs: add Phase 31 verification record
5690b48f  style: format Dart sources tests and tools
980a1bd5  feat: audit Phase 31 qualification reporting files
111c1932  test: align repository audit fixtures with Phase 31
40db1d9f  test: advance continuity contract to Phase 31
5eb6a727  test: guard Phase 31 qualification status wiring
bea5eca0  docs: align repository audit with Phase 31
4dbd71a3  test: harden qualification status failure cases
23a367be  test: reject leftover Phase 31 maintenance helpers
cfec7e42  docs: index Phase 31 qualification reporting
96e32d25  docs: add read-only qualification status workflow
c5bb3afa  chore: finalize Phase 31 continuity safely
923f3a29  test: guard Phase 31 continuity archive and cleanup
6138bf0f  fix: match preserved continuity archive text exactly
```

Additional maintenance-only commits used while safely synchronizing the large historical continuity log are intentionally not treated as product features. The final state preserves the original Phase 0–30 log verbatim and removes all temporary finalizer helpers.

## Verification boundary

The first Phase 31 Dart additions were canonically formatted by the repository-owned Format Dart automation in commit `5690b48f`. Additional source/tests were then added for audit and failure-case hardening.

A newer complete maintained CI/native result has not yet been explicitly accepted into this continuity index, so the latest previously accepted full evidence remains:

- full CI: `32018055661` — **235/235 tests**, **106 files formatter-clean**;
- native matrix: `32015893841`.

This avoids presenting an unobserved workflow result as verified evidence.

## Stable-release boundary retained

The live qualification manifest remains **0/13** passed. Stable `1.5.0` promotion must remain blocked until actual representative-device/accessibility/external-handler/signing/store checks are performed and recorded with verifiable evidence and explicit-timezone timestamps.

Hosted compilation, widget tests, synthetic fixtures, generated artifacts, and documentation reviews are not substitutes for those real-world checks.

# Phase 31 follow-up — Web/PWA metadata hardening

Date: **2026-08-19**

After the qualification-reporting layer was secured, the next safe non-blocking hardening area was the Flutter Web/PWA shell. The changes improve source-controlled install metadata and regression coverage without introducing a server dependency, account system, analytics, advertising, or any claim that a real browser installation has been manually qualified.

## Web App Manifest improvements

`web/manifest.json` now explicitly defines:

- relative app identity: `"id": "."`;
- relative `start_url` and `scope`, both `"."`, retaining root/subpath deployment flexibility;
- source manifest language/direction: English / left-to-right;
- standalone display mode;
- game and entertainment categories;
- project theme/background colors;
- four required install icon entries: regular and maskable 192×192 / 512×512 PNG assets;
- no preference for a separate related native app.

## HTML shell improvements

`web/index.html` now adds:

- `lang="en"` on the root HTML element;
- explicit `light dark` color-scheme metadata;
- generic mobile Web-app capability metadata;
- Apple mobile Web-app capability/title metadata;
- Apple touch icon metadata;
- the existing Flutter base-href placeholder, responsive viewport, project manifest/favicon links, and bootstrap script remain intact.

## Focused Web/PWA regression tests

Added `test/web_pwa_metadata_test.dart` to verify:

- manifest identity/start/scope and language/direction;
- standalone display/categories/colors;
- regular plus maskable 192/512 icon coverage;
- existence and non-zero size of every manifest icon source file;
- HTML document language and install metadata;
- manifest/touch-icon links;
- Flutter base-href, responsive viewport, title, and bootstrap script.

`test/current_release_state_test.dart` also guards the PWA guide, source metadata, and audit wiring so the feature cannot silently disappear from the maintained release state.

## Repository-integrity expansion

The audit now requires:

- `web/index.html`;
- `web/manifest.json`;
- `web/favicon.svg`;
- all four PWA icon assets;
- `docs/PWA.md`;
- `what_changed_archive_phase_00_30.md`.

This protects both the Web install shell and the preserved historical continuity record. Audit fixtures were updated separately to keep clean/fail-closed regression coverage aligned.

## Documentation

Added [`docs/PWA.md`](docs/PWA.md) with:

- source file and manifest contracts;
- root and subpath deployment guidance;
- Flutter base-href boundary;
- install/browser qualification caveats;
- offline-first/browser-storage boundaries;
- automated test scope;
- maintained release-verification sequence.

The guide is indexed in [`docs/README.md`](docs/README.md), the expanded audit behavior is recorded in [`docs/REPOSITORY_AUDIT.md`](docs/REPOSITORY_AUDIT.md), and [`ROADMAP.md`](ROADMAP.md) now records this PWA hardening as completed source work while keeping real browser/PWA lifecycle testing manual.

## Follow-up commit sequence

```text
4006fdbd  feat: harden web app manifest metadata
54a35430  feat: improve web install metadata
a90f3ab5  test: cover web app manifest metadata
ff6a9227  docs: add PWA metadata and deployment guide
ee862cff  docs: index Web PWA hardening guide
c928fe8d  feat: audit Web PWA metadata and continuity archive
f11f6e06  test: align audit fixtures with Web PWA contract
08627b3f  docs: document Web PWA audit coverage
0c274dce  test: guard current Web PWA hardening state
1c9a2f6c  docs: record Web PWA hardening in roadmap
```

## Qualification boundary unchanged

The PWA source hardening does **not** change the live real-world qualification evidence. The stable qualification boundary remains **0/13**. Browser installation UI, installed lifecycle, service-worker behavior, browser storage/caching/eviction, clipboard/file handlers, and real deployed-origin behavior still require representative manual qualification before stable-release claims are made.
