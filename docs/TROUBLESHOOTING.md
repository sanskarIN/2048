# Troubleshooting

This guide covers common development and user-state issues for 2048 Nova. Commands assume the repository root unless stated otherwise.

## Flutter is not found

Check:

```bash
flutter --version
```

If the shell cannot find Flutter, add the Flutter SDK `bin` directory to your system `PATH`, reopen the terminal, and run:

```bash
flutter doctor -v
```

Do not copy SDK binaries into the repository.

## Dependencies do not resolve

Run:

```bash
flutter pub get
```

If the local package cache is inconsistent, use Flutter/Dart package-cache repair mechanisms appropriate to your environment rather than deleting project source files. Keep `pubspec.lock` committed for the application.

## Formatter check fails

CI checks:

```bash
dart format --output=none --set-exit-if-changed lib test
```

To fix formatting locally:

```bash
dart format lib test
```

Review the resulting changes and commit them with the behavior change or a focused style commit.

## `flutter analyze` fails

Run:

```bash
flutter analyze
```

Resolve all analyzer errors before treating a change as complete. A successful formatter run does not imply static analysis will pass.

If a reported issue is in a test, fix the test source rather than suppressing a legitimate analyzer rule without a documented reason.

## Tests fail only because a control is offscreen

Flutter widget tests use a finite test viewport. If production content is intentionally scrollable, a test must scroll the target into view before tapping it. Do not change a correct scrollable production layout solely to satisfy an offscreen test tap.

Use normal finder/scroll helpers and still assert the underlying state transition, not just that a tap did not throw.

## Web build fails

Run the same command as CI:

```bash
flutter build web --release
```

Then check:

- analyzer/test failures first;
- unsupported Web APIs introduced by a new dependency;
- asset paths declared in `pubspec.yaml`;
- generated Web configuration under `web/`.

The project has previously emitted informational font lookup/WASM dry-run messages while still producing a successful Web build. Judge success by the actual command exit result, not by the presence of every warning line.

## Android build issues

Check Android tooling with:

```bash
flutter doctor -v
```

Then:

```bash
flutter pub get
flutter build apk --release
```

Common causes include missing Android SDK components, license acceptance, Java/Gradle environment mismatch, or local emulator/device configuration.

Automated APK build success does not configure a private Play Store signing key for you.

## iOS build/signing issues

The repository CI intentionally uses:

```bash
flutter build ios --release --no-codesign
```

For a real device/App Store build, configure Apple Developer signing and provisioning in the normal Xcode/Flutter environment. Signing certificates and provisioning profiles should not be committed to this public repository.

## Windows/macOS/Linux desktop build issues

Enable the platform as needed:

```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

Only the command supported by the host OS is relevant.

Linux requires native build packages such as GTK development libraries and Ninja; see `.github/workflows/platform-builds.yml` for the CI prerequisite installation.

## Saved game disappears at startup

2048 Nova intentionally removes the current save if it cannot be safely deserialized. Corrupt current-game recovery also clears associated Undo history and the current-game unranked marker to prevent stale state from attaching to another session.

If this happens during development:

1. inspect changes to `GameState.toJson()` / `GameState.fromJson()`;
2. check schema-version logic;
3. add a migration if older valid data must remain supported;
4. add a regression test reproducing the old persisted payload.

Do not weaken validation simply to keep malformed data.

## Undo history is shorter than expected

Undo history is deliberately capped at 50 snapshots. Malformed/stale snapshots are also filtered. Therefore:

- a very long game does not retain unlimited Undo;
- Move Replay may begin after move zero because it reuses retained Undo history;
- importing a portable backup clears previous Undo history.

This is expected behavior.

## Undo restores the board but the next spawn seems wrong

A correct saved snapshot includes RNG state. If a code change causes divergence after Undo/save-resume, inspect deterministic RNG persistence and any new random calls. Hint evaluation and replay must not consume player RNG.

Add a deterministic regression test instead of checking only visible board equality.

## Time Challenge appears expired after reopening

Time Challenge uses persisted `startedAt`; closing the app does not pause or reset its 180-second limit. On restore, the controller reconciles the current status. An expired challenge being marked lost after reopening is expected.

## Daily Challenge differs from the local calendar date

Daily seed calculation uses **UTC**, not local midnight. The seed is `YYYYMMDD` from `DateTime.now().toUtc()`. Near a local date boundary, the UTC date can differ from the device-local date.

## Daily history seems to keep an older score

Daily history preserves the stronger score result. A weaker replay is not allowed to downgrade the stored score. Completion and win flags are sticky. Duplicate records are normalized by seed.

## Challenge Code is rejected

A valid current code must:

- be no more than 1024 characters;
- use the `NOVA1` prefix;
- contain exactly three dot-separated segments;
- contain an 8-character hexadecimal checksum;
- pass checksum verification;
- contain a valid Base64URL/UTF-8 JSON payload;
- use format `2048-nova-challenge` and version `1`;
- contain a strictly valid seeded `GameConfig`;
- use a supported non-Daily mode.

A code edited by hand will normally fail its checksum unless the checksum is recomputed as well. That checksum is only corruption detection, not authentication.

See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## Challenge Code says the checksum does not match

The copied text changed after it was generated. Re-copy the entire code without adding/removing characters. When sending through another app, confirm that line wrapping did not insert spaces or punctuation.

Do not disable checksum verification to make altered input work; generate or obtain a new valid code instead.

## Challenge Code clipboard is empty

`Paste code` reads clipboard text only after you press the button. If the platform returns no usable text, copy the complete Challenge Code again or paste/type it manually into the input field.

Clipboard behavior differs by platform and browser permission model, so real platform qualification is still required before stable release.

## Same Challenge Code produced a different later board

The same supported configuration/seed produces the same **opening** board/RNG state. The deterministic sequence stays aligned when the same valid move sequence is made.

If players make different moves, the set/order of empty cells changes, so boards and later spawn placement can diverge. That is expected and does not indicate a bad code.

Also verify both players used the same complete code and the same app/code schema version.

## Why can’t I create a Daily Challenge Code?

Daily Challenge already uses the UTC date as its shared seed and maintains dedicated date-based history. Challenge Codes intentionally reject Daily mode so arbitrary text cannot masquerade as a date-derived Daily run.

Use the Daily Challenge screen when you want the shared daily seed.

## Challenge Code game changed my statistics

That is intentional. A Challenge Code contains no imported progress or historical record; it starts a fresh normal non-Daily game through the same new-game path as the mode picker. Normal statistics/achievement behavior applies.

This differs from Game Backup, which restores editable board progress and therefore remains unranked.

## Starting a Challenge Code asks to replace my current game

That is expected when a recoverable current game exists. The decoded code is previewed first, and the normal replacement guard prevents silent loss of the saved board/Undo history.

Choose **Keep current game** to cancel without changing the current session.

## Hint does not change the board

That is intentional. Hint is suggestion-only and evaluates copied board states. It does not consume RNG, move tiles, update Undo, or change statistics.

If the game is terminal or there is no legal move, the hint can be unavailable.

## Auto Play Demo does not update statistics

That is intentional. Auto Play Demo uses an isolated in-memory `AutoplaySession`. It is not a player game and does not write current save, lifetime statistics, achievements, or Daily history.

## Move Replay cannot start from move zero

Replay uses the current game plus the **bounded** retained Undo history. Once earlier Undo snapshots have been dropped, Replay cannot reconstruct those old frames. The viewer deliberately discloses this limitation rather than inventing missing moves.

## Game Backup button is disabled

`Copy game backup` requires a current game. Import remains available without a current game.

Start or restore a game before exporting.

## Backup import is rejected

The clipboard text must:

- be non-empty;
- be at most 128 KiB;
- be valid JSON;
- use format `2048-nova-game-backup`;
- use backup envelope version `1`;
- contain a valid timestamp;
- contain a `game` object accepted by strict `GameState` validation.

A Challenge Code is not a Game Backup and cannot be pasted into the Backup importer. Use Home → Challenge Codes for `NOVA1...` text.

See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## Imported game does not increase records or achievements

That is intentional. Every portable imported game is marked **unranked**. The board can be played and saved, but imported play cannot change lifetime records, achievements, streaks, or Daily history.

Start a normal new game to return to ranked/local behavior.

## Imported game's Best value changed

External backup `bestScore` is not trusted as a lifetime record. On import, the game-local display value is normalized against the imported current score and the device's existing local lifetime best. This prevents pasted data from inflating player records.

## External link does not open

The shared external-link helper accepts only supported secure `https` destinations and non-empty `mailto` links. When platform launch fails, the app offers a copy fallback.

If a link consistently fails, verify that the device has an appropriate browser/mail handler and that the destination is one of the configured project links.

## Reset Statistics while a game is active

For a normal local ranked game, reset keeps that active game as the current post-reset session so later win-rate/statistics remain internally coherent. Retained Undo snapshots are normalized so they cannot restore the old lifetime best.

For an imported unranked game, statistics reset does not convert that game into a ranked session.

## Clear All did not erase unrelated preferences

That is intentional. 2048 Nova removes only its project-owned keys. It does not call a blanket `SharedPreferences.clear()`.

Challenge Code clipboard text is controlled by the operating system clipboard and is not a SharedPreferences key, so Clear All does not promise to erase platform clipboard history.

## A GitHub Actions formatting workflow made a commit

`Format Dart` is allowed to commit formatter changes on `main` using `Sanskar <sanskarin@outlook.in>`. It exits without a commit if no formatter changes are needed and skips bot-triggered recursion.

## GitHub Actions shows Node runtime deprecation warnings

Hosted Actions can emit deprecation warnings for action runtime versions even while jobs succeed. Treat them as maintenance signals. Upgrade official action major versions when an appropriate supported release is available and verified; do not confuse a warning with a failed project build.

## Where to report a reproducible bug

Use the repository bug-report template:

https://github.com/sanskarIN/2048/issues/new?template=bug_report.yml

Include:

- platform/OS;
- Flutter version if developing;
- exact steps;
- expected behavior;
- actual behavior;
- relevant logs without secrets;
- whether the issue occurs after a clean new game, Challenge Code start, or restored local/backup data;
- for Challenge Code issues, whether the failure is generation, copy, paste, validation, preview, deterministic opening, or replacement behavior (do not include private clipboard content you do not intend to share).

For security-sensitive reports, follow [`../SECURITY.md`](../SECURITY.md) rather than posting exploit details publicly.
