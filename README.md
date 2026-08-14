<div align="center">
  <img src="assets/branding/2048_nova_logo.svg" alt="2048 Nova logo" width="160" />

# 2048 Nova

**A modern, accessible, offline-first 2048 puzzle game built with Flutter.**

Made by the Sanskar

[Source](https://github.com/sanskarIN/2048) · [Guide](docs/GAME_ENGINE.md) · [Hints](docs/HINT_SOLVER.md) · [Verification](docs/VERIFICATION.md) · [Roadmap](ROADMAP.md) · [Support](SUPPORT.md) · [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN)
</div>

## Overview

2048 Nova preserves the familiar 2048 rules while adding a modern cross-platform interface, deterministic game engine, multiple board sizes and challenge modes, save/resume, robust undo, heuristic hints, an isolated Auto Play demonstration, statistics, achievements, theme palettes, accessibility controls, daily challenges, and open-source project tooling.

The normal game is offline-first. It does not require an account, subscription, analytics service, advertising tracker, or permanent internet connection. Internet access is only needed when a player deliberately opens an external destination such as GitHub, LinkedIn, email, or Buy Me a Coffee.

## Features

- Deterministic, UI-independent 2048 engine with correct one-merge-per-tile behavior.
- Classic 4×4, Quick 3×3, Extended 5×5, Challenge 6×6, Endless, Target, Time Challenge, Move Limit, Daily Challenge, and Zen modes.
- Selectable Target milestones from 128 through 16384.
- Touch/swipe, Arrow Keys, and W/A/S/D movement plus H for Hint, U for Undo, P/Escape for Pause, and R for Restart on keyboard platforms.
- Save/resume with schema-versioned local state, structural validation, startup challenge reconciliation, and corruption-safe self-healing.
- Persistent undo history with deterministic RNG restoration, stale-session filtering, and lifetime-best-score preservation.
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
- GitHub Actions quality checks, platform-build workflows, Dependabot, issue templates, and contribution/security documentation.

## Configured targets

The repository contains Flutter runners for:

- Android
- iOS
- Web / PWA
- Windows
- macOS
- Linux

A target is only described as verified after its corresponding CI/build check has completed successfully. See [`docs/VERIFICATION.md`](docs/VERIFICATION.md) for the compact current evidence and [`what_changed.md`](what_changed.md) for the chronological verification record.

## Controls

| Input | Action |
| --- | --- |
| Swipe | Move in swipe direction |
| Arrow Keys | Move tiles |
| W / A / S / D | Move tiles |
| H | Show the current heuristic hint |
| U | Undo when an undo snapshot is available |
| P or Escape | Open the pause menu |
| R | Restart the current mode, respecting restart confirmation settings |
| Undo button | Restore the previous persisted snapshot |
| Hint button | Suggest a legal direction without changing the board or RNG |
| Pause button | Open the pause menu |
| Restart button | Start the current mode again, with confirmation when enabled |

## Game rules

Each move compresses tiles toward the requested direction, merges adjacent equal values exactly once per source tile, compresses the result, calculates score gain, and only then spawns a new tile if the board actually changed. New tiles are 2 with 90% probability and 4 otherwise.

A non-Endless/Zen target win blocks further moves until the player explicitly chooses Continue or starts another game. Game-over states also block further moves. This keeps board, undo, statistics, and persisted state aligned with the visible terminal dialogs.

The engine stores deterministic RNG state inside the game snapshot. That makes seeded challenges, undo, and save/resume behavior reproducible rather than visually pretending to restore a previous state. See [`docs/GAME_ENGINE.md`](docs/GAME_ENGINE.md).

## Hint solver and Auto Play Demo

Hints are computed locally from copied board data. Every legal direction is simulated without spawning a tile. The solver ranks candidates using mobility/empty cells, immediate merge value, highest-tile corner placement, monotonicity, smoothness, and deterministic tie-breaking.

Requesting a normal hint does not change score, moves, board state, undo history, statistics, achievements, or the next deterministic spawn. The optional Auto Play Demo reuses this heuristic inside its own seeded in-memory Endless sandbox, where automatic demo moves remain separate from the player's game and records.

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
    daily_challenge/
    game/
    guide/
    home/
    modes/
    settings/
    solver_demo/
    splash/
    statistics/
    support/
  shared/
  main.dart
```

- `domain/` contains deterministic game rules, serializable state, the heuristic hint solver, and the isolated autoplay session.
- `data/` owns validated, bounded, self-healing local persistence.
- `app/state/` coordinates player sessions, undo, settings, statistics, achievements, and daily records.
- `features/` contains user-facing screens, including the persistence-free Auto Play Demo.
- `core/` and `shared/` contain design tokens, project metadata, replacement guards, external-link handling, and reusable UI.

More detail: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Dependencies

Runtime dependencies beyond Flutter are intentionally limited to:

- `shared_preferences` — small local game/settings/statistics storage.
- `url_launcher` — safe handoff to browser/email handlers for explicit external actions.

Auto Play Demo adds no network service, model download, or third-party AI dependency.

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

## Quality checks

Before contributing or preparing a release, run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Additional configured platform builds are exercised by GitHub Actions. See [`docs/VERIFICATION.md`](docs/VERIFICATION.md), [`docs/TESTING.md`](docs/TESTING.md), and [`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md).

## Build examples

```bash
flutter build web --release
flutter build apk --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build ios --release --no-codesign
```

Only run commands supported by the current host OS and installed toolchain.

## Accessibility

2048 Nova treats accessibility as a core requirement rather than a decorative option. Current implementation includes board-size semantics, row/column-aware tile labels, keyboard controls, visible numeric values in addition to color, high contrast, reduced motion, responsive text/layout behavior, and explicit labels/tooltips for important controls and external support actions.

See [`docs/ACCESSIBILITY.md`](docs/ACCESSIBILITY.md) for current coverage and release checks.

## Privacy

The default project has no account system, advertising SDK, analytics tracker, or cloud synchronization. Game state, settings, statistics, achievements, and Daily Challenge history are stored locally. Malformed project-owned local data is validated and either repaired or removed instead of being trusted blindly. Auto Play Demo is in-memory only and is discarded when its screen is closed. See [`docs/PRIVACY.md`](docs/PRIVACY.md).

## Branding and assets

The original editable logo source is stored at:

```text
assets/branding/2048_nova_logo.svg
```

A GitHub Actions branding pipeline exports platform-appropriate launcher icons, PWA icons, the iOS launch image, and a reusable 1024×1024 PNG. See [`docs/BRANDING.md`](docs/BRANDING.md).

No proprietary 2048 artwork or copyrighted third-party game assets are bundled.

## Contributing

Contributions are welcome. Please read:

- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)
- [`SECURITY.md`](SECURITY.md)
- [Pull request template](.github/pull_request_template.md)

Use small, coherent changes, add tests for behavior changes and regressions, keep accessibility in scope, and do not commit credentials or private information.

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

Support is optional and is never required to play the game.

## License

2048 Nova is licensed under the [MIT License](LICENSE). Third-party Flutter/package license information remains available through Flutter's standard license interface inside the app.

---

<div align="center">
<strong>Made by the Sanskar</strong>
</div>
