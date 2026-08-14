<div align="center">
  <img src="assets/branding/2048_nova_logo.svg" alt="2048 Nova logo" width="160" />

# 2048 Nova

**A modern, accessible, offline-first 2048 puzzle game built with Flutter.**

Made by the Sanskar

[Source](https://github.com/sanskarIN/2048) · [Documentation](docs/README.md) · [Verification](docs/VERIFICATION.md) · [Roadmap](ROADMAP.md) · [Support](SUPPORT.md) · [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN)
</div>

## Overview

2048 Nova preserves the familiar 2048 rules while adding a modern cross-platform interface, deterministic game engine, multiple board sizes and challenge modes, save/resume, robust Undo, offline shareable seeded Challenge Codes, portable current-game backup/restore, read-only Move Replay, heuristic hints, an isolated Auto Play demonstration, statistics, achievements, theme palettes, accessibility controls, Daily Challenge, and open-source project tooling.

The normal game is offline-first. It does not require an account, subscription, analytics service, advertising tracker, cloud-sync backend, remote AI model, or permanent internet connection. Internet access is only needed when a player deliberately opens an external destination such as GitHub, LinkedIn, email, or Buy Me a Coffee.

The repository is currently on the **`0.9.0+1` release-candidate line**. Automated quality and native build evidence is documented, while physical-device, real screen-reader, signing/provisioning, long-session, and store-release qualification remain explicit manual boundaries before a stable 1.0.0 claim.

## Features

- Deterministic, UI-independent 2048 engine with correct one-merge-per-source-tile behavior.
- Classic 4×4, Quick 3×3, Extended 5×5, Challenge 6×6, Endless, Target, Time Challenge, Move Limit, Daily Challenge, and Zen modes.
- Selectable Target milestones from 128 through 16384.
- Offline **Challenge Codes** that share a supported deterministic game configuration/seed as checksummed `NOVA1...` text without accounts or cloud synchronization.
- Challenge Code validation for size, prefix, checksum, Base64URL/JSON envelope, format/version, strict `GameConfig`, deterministic seed, and supported-mode allowlist; Daily mode is intentionally excluded.
- Touch/swipe, Arrow Keys, and W/A/S/D movement plus H for Hint, U for Undo, P/Escape for Pause, and R for Restart on keyboard platforms.
- Save/resume with schema-versioned local state, structural validation, startup challenge reconciliation, and corruption-safe self-healing.
- Persistent Undo history with deterministic RNG restoration, stale-session filtering, lifetime-best-score preservation, and a 50-snapshot bound.
- **Game Backup** for copying/restoring one current game as validated JSON through the clipboard.
- Portable imported games are always **unranked**, remain unranked after restart, clear unrelated Undo history, and cannot mutate lifetime statistics, achievements, streaks, or Daily results.
- Read-only **Move Replay** built from the current game and validated retained Undo snapshots, with scrub, first/previous/next/latest navigation, play/pause, 1/2/4-frame-per-second playback, defensive copies, and explicit disclosure when bounded history begins after move zero.
- Deterministic non-automatic heuristic hints that evaluate empty cells, merges, corner strategy, monotonicity, and board smoothness without consuming game RNG.
- Optional **Auto Play Demo** with pause/resume, single-step control, speed selection, deterministic seed reset, and demo-only metrics. It uses an isolated heuristic sandbox and never writes player saves, lifetime statistics, achievements, or Daily history.
- Statistics including games, wins, win rate, best score, highest tile, total moves/merges, averages, and streaks.
- Local achievements with progress and unlock dates.
- Date-seeded offline Daily Challenge with deduplicated local history, sticky completion/win state, and best-result preservation across replays.
- Light, dark, and system brightness with Classic Nova, Midnight, Neon, Ocean, Forest, Sunset, and Monochrome palettes.
- High-contrast mode, reduced motion, positional semantic tile labels, keyboard access, visible numeric values, and system text scaling support.
- Confirmation before replacing a recoverable saved game and explicit terminal-game choices.
- Optional lightweight system sound and haptic feedback where supported.
- Responsive board layouts for multiple window and screen sizes.
- Branded splash screen, application icons, and tasteful **Made by the Sanskar** identity.
- Prominent but optional Buy Me a Coffee support entry points plus a direct GitHub bug-report action.
- GitHub Actions quality checks, cross-platform release-build verification, Dependabot, issue templates, and contribution/security documentation.

## Documentation

The complete documentation map is [`docs/README.md`](docs/README.md). Important references include:

| Topic | Document |
| --- | --- |
| Architecture | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| Engine rules | [`docs/GAME_ENGINE.md`](docs/GAME_ENGINE.md) |
| All game modes | [`docs/GAME_MODES.md`](docs/GAME_MODES.md) |
| Challenge Codes | [`docs/CHALLENGE_CODES.md`](docs/CHALLENGE_CODES.md) |
| Hint + Auto Play | [`docs/HINT_SOLVER.md`](docs/HINT_SOLVER.md) |
| Local storage/data | [`docs/DATA_STORAGE.md`](docs/DATA_STORAGE.md) |
| Backup and restore | [`docs/BACKUP_AND_RESTORE.md`](docs/BACKUP_AND_RESTORE.md) |
| Accessibility | [`docs/ACCESSIBILITY.md`](docs/ACCESSIBILITY.md) |
| Privacy | [`docs/PRIVACY.md`](docs/PRIVACY.md) |
| Development | [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) |
| CI/CD | [`docs/CI_CD.md`](docs/CI_CD.md) |
| Testing | [`docs/TESTING.md`](docs/TESTING.md) |
| Verification | [`docs/VERIFICATION.md`](docs/VERIFICATION.md) |
| Troubleshooting | [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) |
| Release qualification | [`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md) |
| Branding | [`docs/BRANDING.md`](docs/BRANDING.md) |
| Dependencies | [`docs/DEPENDENCIES.md`](docs/DEPENDENCIES.md) |
| Chronological implementation log | [`what_changed.md`](what_changed.md) |

## Configured targets

The repository contains Flutter runners for:

- Android
- iOS
- Web / PWA
- Windows
- macOS
- Linux

A target is only described as verified after its corresponding CI/build check has completed successfully. See [`docs/VERIFICATION.md`](docs/VERIFICATION.md) for compact current evidence and [`what_changed.md`](what_changed.md) for the chronological verification record including intermediate failures and fixes.

## Controls

| Input | Action |
| --- | --- |
| Swipe | Move in swipe direction |
| Arrow Keys | Move tiles |
| W / A / S / D | Move tiles |
| H | Show the current heuristic hint |
| U | Undo when a snapshot is available |
| P or Escape | Open the pause menu |
| R | Restart the current mode, respecting restart confirmation settings |
| Undo button | Restore the previous persisted snapshot |
| Hint button | Suggest a legal direction without changing board/RNG |
| Pause button | Open the pause menu |
| Restart button | Start the current mode again, with confirmation when enabled |

## Game rules

Each move compresses tiles toward the requested direction, merges adjacent equal values exactly once per source tile, compresses the result, calculates score gain, and only then spawns a new tile if the board actually changed. New tiles are 2 with 90% probability and 4 otherwise.

A non-Endless/Zen target win blocks further moves until the player explicitly chooses Continue or starts another game. Game-over states also block further moves. This keeps board, Undo, statistics, and persisted state aligned with the visible terminal flow.

The engine stores deterministic RNG state inside the game snapshot. That makes seeded challenges, Undo, and save/resume behavior reproducible rather than visually pretending to restore a previous state. See [`docs/GAME_ENGINE.md`](docs/GAME_ENGINE.md).

## Game modes

Built-in presets are:

1. Classic 4×4 — target 2048.
2. Quick 3×3 — target 512.
3. Extended 5×5 — target 2048.
4. Challenge 6×6 — target 4096.
5. Endless 4×4 — continue beyond nominal 2048.
6. Target 4×4 — choose 128 through 16384.
7. Time Challenge 4×4 — 180-second limit.
8. Move Limit 4×4 — 250 valid moves.
9. Daily Challenge 4×4 — deterministic UTC date seed.
10. Zen 4×4 — low-pressure continuation beyond nominal target.

See [`docs/GAME_MODES.md`](docs/GAME_MODES.md) for precise behavior.

## Shareable seeded Challenge Codes

Home exposes **Challenge Codes** for creating or opening the same deterministic supported game setup without accounts or cloud synchronization.

A code has the form:

```text
NOVA1.<base64url-payload>.<8-hex-checksum>
```

The payload contains only a versioned `GameConfig` plus deterministic seed. It does not contain a current board, score, lifetime statistics, achievements, Daily history, settings, or Undo snapshots. The checksum detects accidental corruption; it is not encryption, authentication, identity proof, or an anti-cheat mechanism.

Supported modes are Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, and Zen. Daily Challenge stays separate because it already uses the UTC date as its shared seed and maintains dedicated history semantics.

Starting a valid code creates a fresh game through the normal new-game path. The same configuration/seed produces the same opening board and RNG state, and identical valid move sequences preserve the same deterministic spawn sequence.

See [`docs/CHALLENGE_CODES.md`](docs/CHALLENGE_CODES.md).

## Save, Undo, and local data

The project stores only project-owned local state through `shared_preferences`. The storage layer validates current game, bounded Undo snapshots, settings, statistics, achievements, Daily history, and the local imported-game unranked marker.

Malformed current-game data is removed safely instead of crashing startup. Bounded collections can self-heal by retaining valid neighbors and rewriting repaired content. Complete data reset removes only 2048 Nova keys rather than clearing unrelated preference keys.

See [`docs/DATA_STORAGE.md`](docs/DATA_STORAGE.md).

## Game Backup

Home exposes **Game Backup**. Export copies a versioned JSON envelope for the current game to the clipboard. It intentionally excludes settings, lifetime statistics, achievements, Daily history, and Undo history.

Import is an untrusted-input boundary. The app checks maximum text size, JSON structure, format/version, timestamp, and strict embedded `GameState` validity, then requires explicit confirmation before replacement.

Every imported game becomes **unranked**. Imported play can continue/save/Undo normally, but cannot change trusted lifetime statistics, achievements, streaks, or Daily Challenge records. An imported backup's embedded historical `bestScore` is not trusted as a lifetime record.

See [`docs/BACKUP_AND_RESTORE.md`](docs/BACKUP_AND_RESTORE.md).

## Move Replay

When a saved game exists, Home exposes **Move Replay**. The viewer builds an in-memory timeline from the current game plus already-validated persisted Undo snapshots. It filters snapshots that do not belong to the current session, rejects impossible future frames, orders frames by move count, and returns defensive copies.

Replay is spectator-only: scrubbing or playing it cannot move the live board, change score, consume RNG, alter Undo, update statistics/achievements, or write Daily Challenge history. Undo storage is intentionally bounded, so a very long game may replay only the most recent retained portion; the UI states this rather than implying a complete history.

## Hint solver and Auto Play Demo

Hints are computed locally from copied board data. Every legal direction is simulated without spawning a tile. The solver ranks candidates using mobility/empty cells, immediate merge value, highest-tile corner placement, monotonicity, smoothness, and deterministic tie-breaking.

Requesting a normal hint does not change score, moves, board state, Undo history, statistics, achievements, or the next deterministic spawn. The optional Auto Play Demo reuses this heuristic inside its own seeded in-memory Endless sandbox, where automatic demo moves remain separate from the player's game and records.

See [`docs/HINT_SOLVER.md`](docs/HINT_SOLVER.md).

## Architecture

The project intentionally keeps the dependency graph small:

```text
lib/
  app/
    state/
  core/
    constants/
    theme/
  data/
  domain/
  features/
    about/
    achievements/
    backup/
    challenge_codes/
    daily_challenge/
    game/
    guide/
    home/
    modes/
    replay/
    settings/
    solver_demo/
    splash/
    statistics/
    support/
  shared/
  main.dart
```

- `domain/` contains deterministic game rules, serializable state, Challenge Code codec, portable backup codec, heuristic hint solver, isolated Auto Play session, and defensive Replay timeline builder.
- `data/` owns validated, bounded, self-healing local persistence.
- `app/state/` coordinates ranked/unranked player sessions, Undo, settings, statistics, achievements, and Daily records.
- `features/` contains user-facing screens including Challenge Codes, Game Backup, Move Replay, and Auto Play Demo.
- `core/` and `shared/` contain design tokens, project metadata, replacement guards, clipboard abstraction, external-link handling, and reusable UI.

More detail: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Dependencies

Runtime dependencies beyond Flutter are intentionally limited to:

- `shared_preferences` — small local game/settings/statistics storage.
- `url_launcher` — safe handoff to browser/email handlers for explicit external actions.

Challenge Codes use Dart JSON/Base64URL and the existing Flutter clipboard abstraction. Game Backup uses Dart JSON and Flutter clipboard APIs. Move Replay and Auto Play Demo add no network service, model download, or third-party AI dependency.

Dependency choices and licensing notes are documented in [`docs/DEPENDENCIES.md`](docs/DEPENDENCIES.md).

## Prerequisites

Install a current stable Flutter SDK and the platform toolchain for the target you want to build. Confirm the environment with:

```bash
flutter doctor -v
```

Then clone and install packages:

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter pub get
```

## Run locally

```bash
flutter run
```

Choose a device explicitly when needed:

```bash
flutter devices
flutter run -d chrome
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

Android/iOS runs require an available emulator/simulator or physical device and the appropriate platform SDK.

For more development detail, see [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).

## Quality checks

Before contributing or preparing a release, run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Additional configured platform builds are exercised by GitHub Actions. See [`docs/CI_CD.md`](docs/CI_CD.md), [`docs/VERIFICATION.md`](docs/VERIFICATION.md), [`docs/TESTING.md`](docs/TESTING.md), and [`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md).

## Build examples

```bash
flutter build web --release
flutter build apk --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build ios --release --no-codesign
```

Only run commands supported by the current host OS and installed toolchain. The iOS `--no-codesign` command verifies compilation only; real device/App Store distribution requires normal Apple signing/provisioning.

## Accessibility

2048 Nova treats accessibility as a core requirement rather than a decorative option. Current implementation includes board-size semantics, row/column-aware tile labels, keyboard controls, visible numeric values in addition to color, high contrast, reduced motion, responsive text/layout behavior, and explicit labels/tooltips for important controls and external support actions. Move Replay reuses the same semantic board renderer and labels its timeline controls. Challenge Codes use standard labeled form controls, selectable generated text, explicit validation messages, and a structured decoded preview.

See [`docs/ACCESSIBILITY.md`](docs/ACCESSIBILITY.md) for current coverage and release checks.

## Privacy

The default project has no account system, advertising SDK, analytics tracker, or cloud synchronization. Game state, settings, statistics, achievements, Daily Challenge history, and the local imported-game ranking marker are stored locally.

Malformed project-owned local data is validated and either repaired or removed instead of being trusted blindly. Move Replay creates only defensive in-memory display copies from existing local game/Undo data, Auto Play Demo is in-memory only, portable Game Backup is copied to the clipboard only after explicit user action, and Challenge Codes are read/written to the clipboard only after explicit Paste/Copy actions. The app never uploads Challenge Codes automatically. See [`docs/PRIVACY.md`](docs/PRIVACY.md).

## Branding and assets

The original editable logo source is stored at:

```text
assets/branding/2048_nova_logo.svg
```

A GitHub Actions branding pipeline exports platform-appropriate launcher icons, PWA icons, iOS launch image, and reusable 1024×1024 PNG. See [`docs/BRANDING.md`](docs/BRANDING.md).

No proprietary 2048 artwork or copyrighted third-party game assets are bundled.

## Contributing

Contributions are welcome. Please read:

- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)
- [`SECURITY.md`](SECURITY.md)
- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md)
- [Pull request template](.github/pull_request_template.md)

Use small, coherent changes, add tests for behavior changes and regressions, keep accessibility/privacy/persistence in scope, and do not commit credentials or private information.

## Troubleshooting

For common setup, analyzer, build, save/Undo, Daily, Challenge Codes, Replay, Auto Play, backup/import, and external-link issues, see [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

## Project links

- Repository: https://github.com/sanskarIN/2048
- Bug report: https://github.com/sanskarIN/2048/issues/new?template=bug_report.yml
- GitHub profile: https://www.github.com/sanskarIN
- LinkedIn: https://www.linkedin.com/in/sanskarIN
- Business: sanskarin@outlook.in
- Business: sanskarin.business@gmail.com
- Support: supportramsandesh@gmail.com

## ☕ Support the project

If you enjoy 2048 Nova and want to support continued development, you can visit:

**https://buymeacoffee.com/sanskarIN**

Support is optional and is never required to play, build, fork, or contribute to the MIT-licensed project.

## License

2048 Nova is licensed under the [MIT License](LICENSE). Third-party Flutter/package license information remains available through Flutter's standard license interface inside the app.

---

<div align="center">
<strong>Made by the Sanskar</strong>
</div>

## Language and localization

2048 Nova supports **English** and **Hindi (हिन्दी)** without requiring a translation service or project server. Settings can follow the supported system locale or explicitly choose English or Hindi. The choice is persisted locally with the existing app settings and malformed/unsupported stored language values safely fall back to System default.

Player-facing Home, modes, gameplay controls/dialogs, Daily Challenge, statistics, achievements, Challenge Codes, Game Backup, Move Replay, Auto Play Demo, Guide, About, Support, external-link fallbacks, and board accessibility semantics use the localization layer. Protocol identifiers such as `NOVA1`, JSON keys, seeds, tile values, URLs, and email addresses remain exact.

See [`docs/LOCALIZATION.md`](docs/LOCALIZATION.md) for architecture, fallback rules, privacy behavior, contributor guidance, automated coverage, and remaining manual Hindi accessibility/layout qualification.
