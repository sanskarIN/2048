# Final Version 2.0.12 Integration Audit

Date: **2026-08-19**  
Source target: **2.0.12+2012**

## Why this audit exists

The earlier Version 2.0.12 source-completion audit was written before the Custom Game Builder feature branch was squash-merged onto `main`. That feature had green automated evidence on an older Version 1.5 base, but historical green CI cannot be relabeled as verification of the later Version 2.0.12 integration.

This audit closes that documentation/evidence gap and defines the final integration-hardening work that must be verified on one current commit.

## Live integration finding

At the start of this pass, live `main` was:

```text
f81076e614b5802af4024588047dd0ba11ce4ce6
```

That commit integrated the Custom Game Builder after the prior Version 2.0.12 documentation/verification checkpoint.

The older Custom Game Builder PR had successfully exercised formatter, analyzer, 285 tests, repository/release gates, Web build, and the configured native build matrix, but its CI log identified the package candidate as `1.5.0+15`. Therefore it remains useful historical feature evidence, not current same-commit `2.0.12+2012` verification.

## Source review result

The integrated custom feature preserves the intended architecture:

- `CustomGamePreset` is a strict versioned domain model;
- custom styles map onto existing `GameMode`/`GameEngine` behavior rather than adding a parallel engine;
- saved presets are local, validated, corruption-safe, case-insensitively deduplicated, and bounded to 24;
- full-data reset removes custom preset/session keys;
- custom-session identity survives save/resume/app restart;
- in-game restart preserves custom-session identity;
- custom sessions do not overwrite built-in per-mode records;
- imported backups remain a separate unranked trust class;
- custom session state is disclosed in the game UI;
- opening the builder does not replace a recoverable game;
- invalid custom form data is rejected before replacement.

## Missing polish completed in this pass

### Edit preset

A saved preset can now be loaded into the builder, changed, and saved back.

Editing supports renaming. If the new name belongs to a different saved preset (case-insensitively), the edit is rejected rather than destructively replacing that other preset.

### Duplicate preset

A saved preset can now be duplicated into the form.

The generated copy name is case-insensitively unique and respects the 40-character name limit. Duplication does **not** write storage immediately; the player reviews/changes the copy and explicitly chooses **Save preset**.

### Cancel edit

A player can leave edit mode without changing persisted presets. The builder returns to its default creation form.

### Narrow/large-text saved-preset actions

The previous trailing row of separate play/delete icons was replaced by a compact popup action menu for Edit, Duplicate, and Delete. Tapping the list item still plays the preset.

The action menu has English/Hindi labels and targeted regression coverage under a narrow 320×640 logical test surface with 2× text scaling.

## Regression coverage added

The final branch adds widget coverage for:

- edit and rename;
- preserving all edited preset configuration fields;
- edit-name collision rejection;
- duplicate as an unsaved copy;
- duplicate configuration preservation;
- cancel-edit behavior;
- narrow/large-text action-menu layout;
- Hindi action-menu labels;
- existing save/play/delete/invalid-seed behavior.

The localized test-app fixture now accepts a `TextScaler` so responsive accessibility regression tests can exercise increased text scaling without duplicating app setup.

## Documentation gaps corrected

The previous `docs/CUSTOM_GAME_BUILDER.md` and `docs/VERSION_1_6_ROADMAP.md` still described the feature as a Version 1.6 branch outside a Version 1.5 candidate.

That wording is obsolete on the integrated Version 2.0.12 source line.

This pass:

- rewrites `CUSTOM_GAME_BUILDER.md` as current Version 2.0.12 behavior;
- converts `VERSION_1_6_ROADMAP.md` into an explicit historical record;
- documents edit/duplicate/collision/cancel behavior;
- documents the custom-vs-built-in record policy;
- documents the unsaved duplicate workflow;
- documents narrow/large-text regression scope;
- preserves the deliberate Custom Challenge Code trust boundary;
- adds an architecture walkthrough;
- adds an error/diagnosis reference;
- adds a new-contributor tutorial;
- adds a documentation audit checklist;
- adds a Linux native-toolchain handbook;
- expands documentation regression protection.

## Deliberate non-goals retained

This final pass does not add features merely to increase scope.

The following remain deliberate non-goals for Version 2.0.12 unless a future release intentionally adopts them:

- cloud accounts or cloud saves;
- analytics/advertising;
- online multiplayer/leaderboards;
- remote AI;
- in-app QR scanning/camera permission;
- custom preset sharing that loses the custom-origin trust marker;
- a new custom-session leaderboard/statistics schema without a comparability/migration design;
- extra languages beyond English/Hindi;
- deeper solver families without a scoped future release.

## Dependency/toolchain decision

No new runtime dependency is required for edit/duplicate/responsive behavior. Reusing existing Flutter widgets/domain/storage avoids expanding privacy, supply-chain, binary-size, or cross-platform plugin risk during the final integration pass.

No Android/Apple/desktop toolchain pin is changed by this work.

## Required automated evidence for this branch

Before the integration is treated as current verified source, the exact final PR head must pass the maintained checks, including:

```text
flutter pub get
Dart formatting
flutter analyze
flutter test --coverage
release-candidate readiness/status gates
repository audit
source-completion audit
solver smoke benchmark
Web release build
Dependency Review
Android APK + AAB build
Linux build
Windows build
macOS build
unsigned iOS build
```

The workflow result itself is the source of truth. This document must not predict success.

## Manual qualification boundary

The release manifest remains **0/13** recorded passed evidence until genuine representative checks are performed.

This source/documentation work does not fabricate:

- physical Android/iOS gameplay/lifecycle checks;
- real responsive/touch/orientation/keyboard/focus checks;
- TalkBack/VoiceOver/Narrator/browser-screen-reader evidence;
- long-session evidence;
- real Challenge Code/Replay/Backup external-handler evidence;
- native splash/icon evidence;
- production signing/provisioning/store metadata evidence.

The stable gate must remain fail-closed while those requirements are pending.

## Final source rule

After the final integration branch is green and merged, further work belongs to maintenance, a reproducible bug/security/accessibility/localization fix, dependency/toolchain/platform maintenance, genuine qualification evidence, or a deliberately scoped future release.

The project should not maintain a hidden “keep adding features forever” backlog inside Version 2.0.12.