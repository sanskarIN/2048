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
- **Active maintenance stream:** Phase 34 — final Version 2.0.12 integration hardening after the Custom Game Builder was merged onto the later release line.
- **Marketing version:** `2.0.12`.
- **Flutter package/build version:** `2.0.12+2012`.
- **Source scope:** feature-complete; Phase 34 fixes integration polish, documentation drift, and verification coverage without reopening a hidden Version 2.0.12 product backlog.
- **PR:** `#25` (`final/v2.0.12-integration-hardening` → `main`).
- **Manual evidence:** stable qualification boundary remains 0/13. No physical-device, assistive-technology, real browser/PWA lifecycle, external-handler, native-branding, signing/provisioning, or store evidence is invented by source/documentation work.
- **Toolchain contract:** CI Flutter 3.47.0 stable; AGP 9.1.0; Kotlin Android 2.4.10; Gradle 9.7.0; Android Java/Kotlin target 17.

The `Current phase: Phase 32` line is intentionally retained because the repository integrity audit treats Phase 32 as the frozen Version 2.0.12 release/source-completion contract. Phase 33 and Phase 34 are maintenance streams inside that completed release line, not new marketing releases.

# Phase 34 — Final Version 2.0.12 integration hardening

Date: **2026-08-19**

## Why this final pass was necessary

Live `main` was inspected instead of relying on the previous checkpoint alone.

The current main head at the start of this work was:

```text
f81076e614b5802af4024588047dd0ba11ce4ce6
```

That commit had integrated the Custom Game Builder after the earlier Version 2.0.12 source-completion/documentation checkpoint.

The Custom Game Builder feature PR had passed formatter, analyzer, 285 tests, Web build, repository/release gates, and the configured native matrix, but the successful CI log showed its base candidate was still:

```text
1.5.0+15
```

Therefore that run remains historical feature evidence. It cannot truthfully be relabeled as same-commit Version `2.0.12+2012` verification after integration into the newer main line.

## Final product polish completed

### Saved custom-preset editing

The Custom Game Builder now supports **Edit preset**.

Editing reloads the complete saved configuration into the form:

- name;
- style;
- board size;
- target;
- style-specific time/move limit;
- deterministic seed.

**Save changes** replaces the original preset, including safe rename behavior.

If an edited preset is renamed to a case-insensitive name already used by a different preset, the update is rejected instead of overwriting the other preset.

### Saved custom-preset duplication

The builder now supports **Duplicate preset**.

Duplication:

- copies the full configuration;
- creates a bounded case-insensitively unique name such as `My Mode copy`;
- respects the 40-character preset-name limit;
- loads the duplicate into the form;
- does not mutate persistent storage until the player explicitly chooses **Save preset**.

This keeps duplication reviewable and prevents accidental one-tap storage changes.

### Cancel editing

**Cancel edit** leaves persistent preset data unchanged and restores the default creation form.

### Responsive saved-preset actions

The previous trailing row of separate saved-preset action icons was replaced by a compact popup menu for:

- Edit preset;
- Duplicate preset;
- Delete preset.

Tapping the preset card itself still starts that preset through the existing replacement guard.

The menu provides more room for preset title/summary content on narrow and large-text layouts.

### English/Hindi polish

The new action names, edit-state helpers, collision feedback, duplicate feedback, update confirmation, and cancel-edit feedback are available in English/Hindi using the builder's existing localization pattern.

## Regression coverage added

`test/custom_game_builder_screen_test.dart` now protects:

- edit and rename;
- preservation of edited style/size/target/limit/seed;
- name-collision rejection;
- duplicate as an unsaved copy;
- duplicated configuration preservation;
- cancel-edit behavior;
- confirmed deletion through the action menu;
- narrow `320×640` test layout;
- `TextScaler.linear(2)` increased-text regression coverage;
- Hindi saved-preset action labels;
- existing save/play/invalid-seed behavior.

`test/support/localized_test_app.dart` now accepts an optional `TextScaler` so accessibility/responsive widget tests can exercise increased text scaling without duplicating localization app setup.

## Trust boundaries preserved

The final custom-preset polish does not change the established trust model:

- custom games reuse existing deterministic `GameConfig`/`GameEngine` behavior;
- no new `GameMode.custom` migration is introduced;
- custom-session identity persists across save/resume/app restart;
- in-game restart preserves custom identity;
- custom games can participate in normal trusted lifetime gameplay progress where existing policy permits;
- custom games cannot overwrite built-in per-mode best-score/highest-tile records;
- imported Game Backup remains a separate unranked trust class;
- replay import remains spectator-only;
- Auto Play remains isolated from player records;
- opening the builder does not replace a recoverable game;
- invalid builder input is rejected before replacement;
- full-data reset removes custom preset/session keys.

## Documentation drift fixed

Two integrated files still described the feature as if it were outside the current release:

- `docs/CUSTOM_GAME_BUILDER.md` said it was Version 1.6 feature-branch documentation;
- `docs/VERSION_1_6_ROADMAP.md` said Version 1.5 remained the current candidate.

Those statements were stale after integration onto the Version 2.0.12 main line.

The final pass:

- rewrote `docs/CUSTOM_GAME_BUILDER.md` for the current Version `2.0.12+2012` implementation;
- converted `docs/VERSION_1_6_ROADMAP.md` into an explicit historical record;
- documented edit/duplicate/cancel/collision behavior;
- documented responsive/large-text regression coverage;
- preserved the custom-session/per-mode-record trust policy;
- preserved the deliberate Custom Challenge Code origin boundary.

## Final documentation expansion

Added:

- `docs/FINAL_2_0_12_INTEGRATION_AUDIT.md` — final same-commit integration/evidence boundary;
- `docs/ARCHITECTURE_WALKTHROUGH.md` — startup/gameplay/persistence/custom/replay/backup/solver/platform/release flow;
- `docs/ERROR_REFERENCE.md` — actionable source/build/platform/trust diagnosis reference;
- `docs/NEW_CONTRIBUTOR_TUTORIAL.md` — new-workstation-to-safe-PR contribution workflow;
- `docs/DOCUMENTATION_AUDIT_CHECKLIST.md` — complete source/docs/release/manual-evidence audit checklist;
- `docs/setup/LINUX_NATIVE_TOOLCHAIN.md` — native Linux compiler/CMake/Ninja/pkg-config/GTK/build/package/diagnosis handbook.

These topics originated as useful unfinished Phase 33 documentation work, but they were recreated on the current integration branch rather than merging an obsolete/conflicting documentation branch onto newer source.

## Documentation regression protection

`test/documentation_completeness_test.dart` now requires and validates the new final documentation.

The new checks protect:

- current Custom Game Builder Version 2.0.12 wording;
- absence of obsolete current Version 1.5/Version 1.6 feature-branch declarations;
- edit/duplicate/cancel/collision/trust documentation;
- historical labeling of the former Version 1.6 roadmap;
- final integration audit and same-commit evidence rule;
- architecture trust boundaries;
- contributor Conventional Commit/safe-change rules;
- error diagnostics;
- Linux native commands/bundle guidance;
- documentation audit coverage.

## Phase 34 commits before final CI correction

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
```

This active continuity rotation is intentionally a separate commit so Phase 33 preservation and Phase 34 activation remain reviewable independently.

## PR and verification boundary

PR #25 was opened from:

```text
final/v2.0.12-integration-hardening
```

to:

```text
main
```

The exact PR head must pass the repository-maintained automated checks before merge.

Expected automated coverage includes:

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

The pull-request workflow must also provide the configured Dependency Review and native Platform Builds evidence for Android APK/AAB, Linux, Windows, macOS, and unsigned iOS where triggered.

No success is claimed in this record until GitHub reports it for the exact current head.

## Manual stable-release boundary

Phase 34 does not alter the real-world release manifest.

The stable qualification boundary remains 0/13 until genuine representative checks are completed and recorded. Source changes, documentation expansion, commit count, hosted tests, or hosted native compilation cannot be substituted for those manual results.

## Final scope rule

Version 2.0.12 remains source-feature-complete after this pass.

The following are deliberately **not** treated as hidden missing work:

- cloud accounts/saves;
- analytics/ads;
- online leaderboards/multiplayer;
- remote AI;
- in-app QR scanning/camera permission;
- unsafe custom-preset Challenge Code sharing without origin semantics;
- a custom leaderboard/statistics schema without a comparability/migration design;
- extra languages beyond English/Hindi;
- additional solver families without a deliberately scoped future release.

Future changes should be reproducible fixes, security/accessibility/localization corrections, dependency/toolchain/platform maintenance, genuine qualification evidence, documentation maintenance, or intentionally scoped future-release functionality.