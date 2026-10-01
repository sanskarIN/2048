# Historical Version 1.6 Roadmap — Custom Game Builder

> **Historical record.** This document preserves the development intent of the original Custom Game Builder branch. It is not the current release roadmap. The current source line is **2048 Nova 2.0.12+2012**; use [`../ROADMAP.md`](../ROADMAP.md), [`CUSTOM_GAME_BUILDER.md`](CUSTOM_GAME_BUILDER.md), and [`FINAL_2_0_12_SOURCE_AUDIT.md`](FINAL_2_0_12_SOURCE_AUDIT.md) for current status.

## Original feature foundation — completed

The original development line established:

- validated `CustomGamePreset` schema/versioning;
- board sizes from 3×3 through 8×8;
- Target, Endless, Timed, and Move Limit custom styles mapped onto the existing deterministic engine;
- optional deterministic seeds;
- bounded local preset storage with corruption repair and case-insensitive name deduplication;
- maximum 24 saved custom presets;
- English/Hindi Custom Game Builder UI;
- save, play, and confirmed-delete flows;
- current-game replacement protection before starting a custom game;
- full-data reset coverage for preset/session keys;
- persisted custom-session identity across app restart;
- custom-session isolation from built-in per-mode best-score/highest-tile records;
- imported-backup isolation from the custom-session marker;
- custom identity preserved across in-game restart;
- localized **Custom game** disclosure in the live game screen;
- domain, persistence, widget-flow, reset, and trust-policy regressions;
- dedicated architecture/policy documentation in `CUSTOM_GAME_BUILDER.md`.

## Original follow-up polish — now completed on the integrated source line

The following items were originally listed as future polish and have now been completed in the Version 2.0.12 integration-hardening work:

- **Edit preset** support, including rename behavior.
- Refusal to overwrite another existing preset when an edited preset is renamed to a conflicting name.
- **Duplicate preset** support with a generated unique copy name and no storage mutation until the user explicitly saves it.
- **Cancel edit** behavior that leaves persisted data unchanged.
- Compact saved-preset action menu for better narrow-layout behavior.
- English/Hindi saved-preset action labels and feedback.
- Narrow-screen and increased-text-scale widget regression coverage.
- Current documentation/index/user-guide integration.
- Current release-line documentation that explains the custom-vs-built-in record boundary.

## Deliberately not converted into a hidden backlog

### Custom aggregate statistics

Custom sessions can differ materially from built-in presets, so introducing a new aggregate record category requires a deliberate data model and comparability policy. Version 2.0.12 does not silently create one.

The current policy is intentionally simple:

- custom local play may contribute to ordinary lifetime gameplay totals/achievements where existing trusted-session rules allow it;
- custom sessions cannot overwrite built-in per-mode records;
- no separate custom leaderboard/record surface is claimed.

A future product release may introduce a separately defined custom-statistics model if there is a concrete need and migration/testing plan.

### Challenge Code sharing

The existing `NOVA1` codec can represent the underlying `GameConfig`, but it does not encode whether the configuration originated from Custom Game Builder. Sharing a custom configuration through the current protocol could therefore cause the receiver to start it as an ordinary built-in-mode session and mix incomparable custom results into built-in per-mode records.

Do not expose a custom-preset Challenge Code button until an intentional versioned design preserves the custom-session trust boundary. Possible future designs include:

- a validated origin field with explicit custom-session semantics; or
- a separately versioned custom-challenge protocol with equally strict parsing and trust-policy tests.

Daily Challenge remains isolated from arbitrary portable configuration injection.

## Verification history and current rule

The original feature branch received green formatter/analyzer/test/Web/native evidence while based on an older release line. After it was integrated into the later Version 2.0.12 source line, that historical result could not truthfully be relabeled as same-commit Version 2.0.12 evidence.

Therefore the final integration-hardening branch must run the maintained Version 2.0.12 gates again. Only successful results from the exact current integration commit may become current automated evidence.

The real-world qualification manifest remains separate and fail-closed. Hosted compilation and widget tests do not invent physical-device, assistive-technology, external-handler, native-branding, signing/provisioning, or store evidence.

## Historical status

This roadmap is **closed as an active roadmap**. It remains tracked only for development traceability. Any new product functionality starts a deliberately scoped future release rather than reopening this historical Version 1.6 plan.