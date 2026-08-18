# Version 1.6 Roadmap — Custom Game Builder

> Draft development roadmap. Version 1.5 remains the current release-candidate line and its 13 real-world qualification checks remain independent.

## Implemented on the Version 1.6 feature branch

- Validated `CustomGamePreset` domain model with schema versioning.
- Board sizes from 3×3 through 8×8.
- Target, Endless, Timed, and Move Limit custom styles mapped onto the existing deterministic engine.
- Optional deterministic seed.
- Bounded local preset storage with corruption repair and case-insensitive name deduplication.
- Maximum 24 saved custom presets.
- English/Hindi Custom Game Builder UI.
- Save, play, and delete preset flows.
- Existing game-replacement confirmation before actually starting a custom game.
- Full-data reset removes custom presets and custom-session identity.
- Persisted custom-session marker across app restart.
- Custom local play remains trusted gameplay but cannot overwrite built-in per-mode best-score/highest-tile records.
- Imported backups remain separately unranked and clear custom-session identity.
- Domain, persistence, widget-flow, reset, and custom-session policy regression coverage.
- Dedicated architecture/policy documentation in `CUSTOM_GAME_BUILDER.md`.

## Required before the feature PR can leave draft

1. `dart format` must report no changes on `lib`, `test`, and `tool`.
2. `flutter analyze` must report no issues.
3. The complete regression suite must pass with the new tests included.
4. Repository audit and Version 1.5 release-candidate gate must remain green; the stable gate must remain fail-closed at the genuine 0/13 manual boundary.
5. Web release build must still succeed without missing-font warnings.
6. Native matrix must continue to compile Android APK/AAB, Linux, Windows, macOS, and unsigned iOS.
7. Custom games must remain isolated from built-in per-mode records after save/resume and restart.
8. Opening the builder must never replace the current game; only an explicit play action may invoke the existing replacement guard.
9. Clear-all-data behavior must remove every custom preset/session key.
10. New user-facing documentation must explain the custom-vs-built-in record boundary.

## Next polish after the first green CI

- Add an explicit localized **Custom** indicator on the live game screen when a custom session is active.
- Add edit/duplicate support for an existing saved preset without creating ambiguous duplicate names.
- Add delete confirmation for saved presets.
- Add documentation-index entries and user-guide coverage.
- Add responsive and large-text widget tests for the builder form and saved-preset list.
- Add targeted semantics tests for the builder controls and saved-preset actions.

## Deliberately deferred

### Challenge Code sharing

The existing `NOVA1` codec can represent the underlying `GameConfig`, but it does not encode whether the configuration originated from Custom Game Builder. Sharing a custom configuration through the current protocol would therefore allow a receiver to start it as an ordinary built-in-mode session and could mix incomparable custom results into built-in per-mode records.

Do not expose a custom-preset Challenge Code button until one of these designs is implemented and tested:

- a backward-compatible authenticated/validated origin field with explicit custom-session semantics; or
- a separately versioned custom-challenge protocol with an equally strict parser and trust policy.

Daily Challenge remains isolated from arbitrary portable configuration injection.

### Stable release promotion

Version 1.6 development does not change the Version 1.5 stable-release qualification manifest. No Version 1.5 device/accessibility/signing/store evidence may be inferred from Version 1.6 automated tests.

## Candidate completion definition

The initial Version 1.6 Custom Game Builder feature is ready for merge only when source, tests, documentation, trust boundaries, reset behavior, and configured builds are all green on the same reviewed feature-branch commit. Real-device/responsive/accessibility checks for the new builder then belong to the Version 1.6 release-qualification plan rather than being silently inherited from Version 1.5.
