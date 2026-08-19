# Custom Game Builder

> Current source target: **2048 Nova 2.0.12+2012**. Custom Game Builder is part of the current integrated source tree. Stable distribution still depends on the repository's automated gates and genuine 0/13 real-world qualification evidence.

## Purpose

Custom Game Builder lets a player create reusable local 2048 configurations without changing the deterministic engine or inventing a parallel rules implementation.

The builder reuses the existing `GameConfig` and `GameEngine` boundaries. A custom preset selects only already-supported deterministic parameters:

- board size from **3×3 through 8×8**;
- target tile from the supported power-of-two target set exposed by the UI;
- one style: **Target**, **Endless**, **Timed**, or **Move Limit**;
- a style-specific time or move limit where applicable;
- an optional deterministic random seed.

## Domain model

`lib/domain/custom_game_preset.dart` owns the versioned `CustomGamePreset` model.

Current schema:

```text
schemaVersion = 1
name
style
size
target
moveLimit
timeLimitSeconds
seed
```

Validation is fail-closed:

- name must contain 1–40 non-whitespace characters after trimming;
- board size must be 3–8;
- target must be a supported power of two within the engine's safe numeric range;
- seed, when present, must be an integer from 0 through `0x7fffffff`;
- Target and Endless do not accept a time/move limit;
- Timed requires exactly a valid time limit;
- Move Limit requires exactly a valid move limit.

Malformed persisted data is rejected with `FormatException` rather than partially accepted.

## Engine mapping

Custom styles intentionally map to existing tested engine modes:

| Custom style | Engine mode |
| --- | --- |
| Target | `GameMode.target` |
| Endless | `GameMode.endless` |
| Timed | `GameMode.timeChallenge` |
| Move Limit | `GameMode.moveLimit` |

There is deliberately no new `GameMode.custom` enum member. This avoids unnecessary migrations across saved games, replay archives, localization switches, statistics serialization, Challenge Codes, and other exhaustive mode logic.

## Local preset persistence

`lib/data/custom_preset_store.dart` stores presets under:

```text
nova.custom_game_presets.v1
```

The store:

- validates every record on load;
- drops malformed records while preserving valid neighbors;
- deduplicates names case-insensitively;
- keeps at most **24** presets;
- rewrites repaired data after recovery;
- removes malformed top-level storage instead of crashing;
- exposes an explicit clear operation.

`LocalStore.clearAll()` also removes this key, so **Clear all local data** retains its promise to remove every project-owned user-data category.

## Create, edit, duplicate, play, and delete

`lib/features/modes/custom_game_builder_screen.dart` provides a complete local preset workflow:

1. Choose the board size, target, style, optional limit, and optional deterministic seed.
2. Choose **Play now** to start the validated configuration without saving it.
3. Choose **Save preset** to store it locally for reuse.
4. Open a saved preset's action menu and choose **Edit preset** to load its values back into the form.
5. While editing, **Save changes** replaces the original preset. Renaming is supported, but an edit cannot overwrite a different existing preset name.
6. Choose **Cancel edit** to leave the stored preset unchanged and restore the default creation form.
7. Choose **Duplicate preset** to load an unsaved copy with a generated case-insensitively unique name such as `My Mode copy`. Review or modify it, then save when ready.
8. Choose **Delete preset** and explicitly confirm before persistent deletion.

Duplicate is intentionally a two-step action: loading a copy does not mutate storage until the user chooses **Save preset**.

The compact action menu avoids a trailing row of multiple icon buttons, which gives saved-preset cards more room on narrow and large-text layouts.

## Custom-session identity and statistics

A custom game is trusted local gameplay, but its configuration may not be comparable to a built-in preset. For example, an 8×8 Target game must not overwrite the best record displayed for the built-in 4×4 Target mode.

To preserve that boundary, the controller persists a separate session marker:

```text
nova.current_game_custom.v1
```

The marker is deliberately separate from `GameState` serialization so existing save, Challenge Code, replay, and backup formats do not need a migration solely for UI-origin metadata.

Policy:

- custom games are **not** imported/unranked backups;
- they may contribute to normal lifetime gameplay totals and achievements;
- they **do not update built-in per-mode best-score/highest-tile records**;
- the custom identity survives save/resume, app restart, and in-game restart;
- the game screen discloses the active custom-session identity;
- starting a normal built-in game clears the custom identity;
- importing a portable backup clears the custom identity and keeps the existing unranked-import policy;
- clearing the active game or all app data removes the marker.

## Replacement safety

Opening the builder does not replace the current game. The existing game-replacement guard runs only when the player chooses to start a custom configuration.

Invalid form input is rejected before the current game can be replaced.

## Localization and accessibility

The builder has English and Hindi labels for its controls, saved-preset actions, confirmation dialogs, validation feedback, and custom-session disclosure.

Automated widget coverage includes:

- English and Hindi rendering;
- narrow layout behavior;
- increased text scaling;
- the preset action menu remaining reachable without layout exceptions;
- visible user-action hit testing;
- custom-session semantics/disclosure.

Automated semantics and layout tests are regression protection, not a substitute for real TalkBack/VoiceOver/Narrator/browser-screen-reader checks in the manual release qualification plan.

## Privacy and offline behavior

Custom presets are local-only. Creating, editing, duplicating, saving, deleting, or playing a preset does not require:

- an account;
- analytics;
- advertising;
- a backend;
- cloud synchronization;
- remote AI;
- network access.

## Challenge Code boundary

The existing `NOVA1` Challenge Code can describe the underlying `GameConfig`, but it does not encode the Custom Game Builder origin/trust marker.

For that reason the app does **not** expose a custom-preset sharing button that would silently turn a custom configuration into an ordinary built-in ranked session on another installation. Sharing this origin safely would require a separately versioned/validated protocol or an intentional compatible origin field with matching trust-policy tests.

Daily Challenge remains isolated from arbitrary portable configuration injection.

## Tests

Focused coverage protects:

- domain validation and JSON round trips;
- style-to-engine mapping;
- invalid schema/style/number rejection;
- local preset persistence, deduplication, corruption repair, and bounds;
- full-data reset behavior;
- bilingual builder rendering and user flows;
- save, edit, rename, collision rejection, duplicate, cancel-edit, and confirmed-delete behavior;
- narrow/large-text saved-preset actions;
- invalid seed rejection before replacement;
- custom-session persistence across restart;
- custom identity across in-game restart;
- built-in per-mode-record isolation;
- restoration of normal record behavior after starting a built-in game.

## Release boundary

Custom Game Builder is now integrated with the Version 2.0.12 source line. Its earlier green feature-branch CI was based on an older release line, so the final integration branch must pass formatter, analyzer, full tests, repository/source audits, Web build, dependency review, and configured native builds again on the current Version 2.0.12 base before that result is treated as current automated evidence.

Real-device, responsive, accessibility, external-handler, signing, native-branding, and store qualification remain genuine manual evidence and must never be inferred from hosted tests.