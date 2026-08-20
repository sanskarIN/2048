# 2048 Nova — Active Continuity

This is the active Version 2.0.12 final-integration maintenance record.

Historical continuity is preserved in:

- [`what_changed_archive_phase_00_30.md`](what_changed_archive_phase_00_30.md) — Phases 0–30;
- [`what_changed_archive_phase_31.md`](what_changed_archive_phase_31.md) — Phase 31;
- [`what_changed_archive_phase_32.md`](what_changed_archive_phase_32.md) — Version 2.0.12 migration/source-completion record;
- [`what_changed_archive_phase_33.md`](what_changed_archive_phase_33.md) — complete documentation/toolchain lifecycle hardening record;
- [`CHANGELOG_ARCHIVE_PRE_2_0_12.md`](CHANGELOG_ARCHIVE_PRE_2_0_12.md) — pre-2.0.12 changelog history.

## Current repository state

- **Current phase:** Phase 32 — Version 2.0.12 source-completion/release audit contract remains the canonical release phase protected by `tool/repository_audit.dart`.
- **Completed maintenance stream:** Phase 33 — complete documentation, setup, command, terminology, file-coverage, and support-lifecycle hardening.
- **Active maintenance stream:** Phase 34 — final Version 2.0.12 integration hardening after Custom Game Builder entered the later release line.
- **Marketing version:** `2.0.12`.
- **Flutter package/build version:** `2.0.12+2012`.
- **Source scope:** feature-complete; Phase 34 fixes integration bugs, product polish, documentation drift, and verification coverage without reopening a hidden Version 2.0.12 feature backlog.
- **PR:** `#25` (`final/v2.0.12-integration-hardening` → `main`).
- **Manual evidence:** stable qualification boundary remains 0/13. No physical-device, assistive-technology, real browser/PWA lifecycle, external-handler, native-branding, signing/provisioning, or store evidence is invented by source/documentation work.
- **Repository settings:** issue #12 remains open because `main` now reports `protected: true`, but the available GitHub connector cannot inspect/write the underlying ruleset and legacy protection metadata still does not prove the intended required CI contexts. This is an external repository-setting boundary, not a missing tracked source feature.
- **Toolchain contract:** CI Flutter 3.47.0 stable; AGP 9.1.0; Kotlin Android 2.4.10; Gradle 9.7.0; Android Java/Kotlin target 17.

The `Current phase: Phase 32` line is intentionally retained because the repository integrity audit treats Phase 32 as the frozen Version 2.0.12 release/source-completion contract. Phase 33 and Phase 34 are maintenance streams inside that completed release line, not new marketing releases.

# Phase 34 — Final Version 2.0.12 integration hardening

Date: **2026-08-19**

## Starting live source

The final pass inspected the live repository rather than assuming the older checkpoint was still current.

`main` started this pass at:

```text
f81076e614b5802af4024588047dd0ba11ce4ce6
```

That commit had squash-merged Custom Game Builder after the earlier Version 2.0.12 source-completion/documentation checkpoint.

The feature's earlier successful CI log identified its candidate as:

```text
1.5.0+15
```

That older run remains useful historical feature evidence but cannot be relabeled as same-commit Version `2.0.12+2012` verification after later integration.

## Product work completed

### Edit saved custom presets

Custom Game Builder now supports **Edit preset**. Loading a preset restores its name, style, board size, target, style-specific limit, and deterministic seed.

**Save changes** safely replaces the original preset. Renaming is supported, but an edit is rejected if the requested name belongs case-insensitively to a different saved preset.

### Duplicate saved custom presets

**Duplicate preset** loads a full copy into the form with a bounded case-insensitively unique name such as `My Mode copy` / `My Mode copy 2`.

The generated name respects the 40-character domain limit. Duplication deliberately does not mutate storage until the player explicitly chooses **Save preset**.

### Cancel edit

**Cancel edit** leaves the stored preset unchanged and restores the default creation form.

### Responsive action menu

Saved-preset Edit/Duplicate/Delete actions use a compact popup menu instead of a wide trailing icon row. Tapping the preset card itself still starts that preset through the existing replacement guard.

This provides more space for long names/summaries under narrow layouts and increased text scaling.

### Edit/Duplicate return to the form

The final last-chance UX audit found that Edit/Duplicate could correctly load a saved configuration while leaving the user scrolled down at the saved-preset card list.

The builder now owns a `ScrollController`. After Edit or Duplicate populates the form, a post-frame callback jumps to the scroll view's minimum extent. This deliberately avoids animation and automatic focus, so it also avoids forcing the keyboard or introducing a reduced-motion concern.

Widget regressions now require the first form `TextField` to be hit-testable immediately after Edit and Duplicate actions launched from saved cards.

### English/Hindi behavior

New action labels, editing helper text, rename-collision feedback, duplicate feedback, update confirmation, and cancel-edit feedback are available in English and Hindi.

## Selector-state bug found and fixed during self-review

A separate integration bug was found after the initial Edit/Duplicate implementation.

`DropdownButtonFormField.initialValue` initializes a FormField but does not automatically reset that FormField's internal selected value merely because the owning state variable changes later. Therefore loading a saved preset could update `_style`, `_size`, `_target`, `_timeLimit`, and `_moveLimit` while a selector still visually displayed its older initial choice.

The builder now gives those selectors value-dependent keys:

```text
custom-style-<style>
custom-size-<size>
custom-target-<target>
custom-time-<seconds>
custom-move-<moves>
```

When Edit, Duplicate, or Cancel changes the loaded configuration, the affected FormField is recreated with the correct current value.

Regression tests assert the visible selector keys after:

- editing a Timed 5×5 / target 4096 / 90-second preset;
- duplicating a Move Limit 6×6 / target 8192 / 500-move preset;
- cancelling back to the default Target 4×4 / target 2048 form.

This protects actual UI state instead of only checking the eventually saved model.

## Existing trust boundaries preserved

The final custom-preset work does not create a parallel engine or weaken existing policy:

- Custom Game Builder maps validated presets to existing deterministic `GameConfig`/`GameEngine` behavior.
- No `GameMode.custom` migration is introduced.
- Custom-session identity survives save/resume, application restart, and in-game restart.
- Custom sessions cannot overwrite built-in per-mode best-score/highest-tile records.
- Imported Game Backup remains a separate unranked trust class.
- Replay import remains spectator-only.
- Auto Play remains isolated from player records.
- Opening the builder does not replace a recoverable game.
- Invalid builder input is rejected before replacement.
- Full-data reset removes custom preset/session keys.
- The current `NOVA1` protocol does not encode custom origin, so unsafe custom-preset sharing is not exposed as if it preserved the record boundary.

## Documentation corrected and completed

The integrated source still contained stale current-state wording:

- `docs/CUSTOM_GAME_BUILDER.md` described a Version 1.6 feature branch;
- `docs/VERSION_1_6_ROADMAP.md` said Version 1.5 remained the current release-candidate line;
- `docs/USER_GUIDE.md` still contained an obsolete “stable 1.0.0” manual-qualification phrase;
- the public root `README.md` did not expose the already-integrated Custom Game Builder feature.

Phase 34 corrected those contradictions and integrated Custom Game Builder into current Version 2.0.12 documentation.

Added/expanded:

- `README.md` — public Custom Game Builder feature/trust/build/documentation visibility;
- `docs/FINAL_2_0_12_INTEGRATION_AUDIT.md` — final same-commit integration/evidence boundary;
- `docs/ARCHITECTURE_WALKTHROUGH.md` — startup/gameplay/persistence/custom/replay/backup/solver/platform/release flow;
- `docs/ERROR_REFERENCE.md` — actionable source/build/platform/trust diagnosis reference;
- `docs/NEW_CONTRIBUTOR_TUTORIAL.md` — new-workstation-to-safe-PR workflow;
- `docs/DOCUMENTATION_AUDIT_CHECKLIST.md` — source/docs/release/manual-evidence audit checklist;
- `docs/setup/LINUX_NATIVE_TOOLCHAIN.md` — Clang/CMake/Ninja/pkg-config/GTK/native bundle/diagnosis handbook;
- `docs/setup/README.md` — Linux-native/contributor/diagnosis navigation;
- `docs/README.md` — canonical index/source map for all final guides and Custom Game Builder;
- `docs/USER_GUIDE.md` — complete custom create/play/save/edit/duplicate/cancel/delete/trust/player workflow;
- `docs/FEATURE_REFERENCE.md` — Custom Game Builder integrated into the consolidated product surface;
- `docs/CUSTOM_GAME_BUILDER.md` — current implementation, selector refresh, saved-card action navigation, trust, persistence, localization, and tests;
- `CHANGELOG.md` — final integration fixes/evidence boundary;
- `test/documentation_completeness_test.dart` — regression guards for public/canonical documentation/navigation/continuity.

Phase 33 continuity was preserved verbatim in `what_changed_archive_phase_33.md` before the active file rotated to Phase 34.

## Final stale-source sweep

Repository search after the documentation fixes returned no current searchable occurrences of the obsolete phrases:

```text
Version 1.6 feature branch documentation
Version 1.5 remains the current release-candidate line
before stable 1.0.0
```

A final unresolved-marker search also returned no current searchable `TODO`, `FIXME`, `HACK`, or `unimplemented` marker requiring implementation.

## Repository hygiene

The obsolete/conflicting documentation PR #24 was closed as superseded after its useful non-duplicative documentation was carried forward onto current Version 2.0.12 source in PR #25.

The only open repository issue found by the final issue sweep is issue #12, which concerns GitHub repository settings rather than tracked source. It remains open because the current connector cannot verify the full ruleset/required-check configuration.

## Phase 34 commit sequence

```text
519b6ad8  feat: add custom preset edit and duplicate workflows
eb256a73  test: support large-text localized widget fixtures
cf9b7d6a  test: cover custom preset editing duplication and responsive actions
2b7d47b1  docs: integrate custom game builder into Version 2.0.12
c4eb3d76  docs: archive the Version 1.6 custom builder roadmap
c721c8f2  docs: add current architecture walkthrough
6e5f4904  docs: add error and diagnosis reference
1f4fe13d  docs: add zero-to-safe-change contributor tutorial
669518cf  docs: add complete documentation audit checklist
8a95f223  docs: add Linux native toolchain handbook
311e0ed2  docs: record final Version 2.0.12 integration audit
258d26ea  test: protect final integration documentation
9bebaa22  docs: archive completed Phase 33 continuity
0dbac3ba  docs: activate final integration continuity
167134ab  fix: refresh custom preset selectors when loading forms
bf0ea7ca  test: verify loaded custom preset selector state
b41fbce5  docs: link the Linux native toolchain handbook
fc563698  docs: integrate final guides into the canonical index
b6b1e24e  docs: add the complete custom game player workflow
fe4550a3  docs: integrate custom games into the feature reference
441de059  docs: record final integration fixes in the changelog
bf444910  test: protect final documentation navigation and continuity
c0bf9b8e  docs: finalize Phase 34 continuity
51cde615  test: harden final documentation assertions
64b3aa90  docs: expose Custom Game Builder in the public README
a3ee2690  test: protect the public Custom Game Builder documentation
1ee3fe6a  fix: return to custom form after preset actions
a3ae2903  test: verify preset actions return to the form
7b9afc2e  docs: document preset action form navigation
d4fc5118  docs: record final custom builder navigation fix
```

This continuity update is intentionally another separate reviewable commit rather than rewriting an earlier implementation/test/docs commit.

## Automated verification boundary

PR #25 is the integration branch that must supply current same-commit evidence.

The maintained quality path includes:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

Pull-request verification should also include the configured Platform Builds matrix for Android APK/AAB, Linux, Windows, macOS, and unsigned iOS. Dependency Review is path-filtered and applies when dependency-sensitive files change; PR #25 does not change `pubspec.yaml`, `pubspec.lock`, Android files, or workflow files.

No formatter/analyzer/test/Web/native success is claimed merely from commits being pushed. The exact final PR head must be observed before merge/promotion.

## Manual stable-release boundary

Phase 34 does not alter the canonical real-world evidence manifest.

The stable qualification boundary remains 0/13 until genuine representative checks are completed and recorded. Source changes, documentation expansion, commit count, widget tests, or hosted compilation cannot substitute for those manual observations.

## Final scope rule

Version 2.0.12 remains feature-complete after this pass. The following are deliberate non-goals rather than missing implementation:

- cloud accounts/saves;
- analytics/ads;
- online leaderboards/multiplayer;
- remote AI;
- in-app QR scanning/camera permission;
- custom-preset Challenge Code sharing that loses custom-origin semantics;
- a custom leaderboard/statistics schema without a comparability/migration design;
- extra languages beyond English/Hindi;
- additional solver families without a deliberately scoped future release.

Future work belongs to reproducible bug/security/accessibility/localization fixes, dependency/toolchain/platform/CI maintenance, genuine manual qualification evidence, documentation maintenance, or a deliberately scoped future release.