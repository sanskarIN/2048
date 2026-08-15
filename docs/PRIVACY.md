# Privacy

2048 Nova is designed as an offline-first game. The default codebase does not add analytics, advertising trackers, accounts, cloud synchronization, remote AI services, or background telemetry.

## Local project data

The application stores project-owned game data locally through Flutter's SharedPreferences abstraction, including:

- current saved game state;
- bounded Undo snapshots;
- settings;
- lifetime statistics;
- achievement unlock timestamps;
- bounded Daily Challenge history;
- a boolean marker indicating whether the current game was restored from a portable backup and must remain unranked.

Saved structures are validated before use. Malformed current-game data fails safely, while bounded Undo/Daily collections retain valid neighboring records when repair is possible.

A complete project reset removes only 2048 Nova's project-owned keys. It does not intentionally wipe unrelated preference keys.

Challenge Code text is **not** stored as an additional app history/database. Once a code is started, only the resulting normal game/session data follows the standard local persistence path.

See [`DATA_STORAGE.md`](DATA_STORAGE.md) for the exact current key set and repair behavior.

## Shareable Challenge Codes and clipboard data

Challenge Codes are explicit user actions and work without a server.

A generated code contains only:

- format/version metadata;
- supported game mode/configuration;
- deterministic random seed.

It does not contain current board progress, score, lifetime statistics, achievements, Daily history, settings, Undo snapshots, or an account identifier.

Selecting **Copy challenge code** writes the generated text to the system clipboard. Selecting **Paste code** reads clipboard text. The app does not read or write Challenge Code clipboard text in the background and does not upload codes automatically.

Challenge Code text is plain and not encrypted. Its checksum is only for accidental corruption detection. Share a code only through channels you choose and remember that the operating system/platform controls clipboard history and cross-device clipboard behavior.

See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## Portable Game Backup and clipboard data

Game Backup is an explicit user action. Export creates plain JSON text for the **current game only** and writes that text to the system clipboard.

The backup intentionally excludes:

- settings;
- lifetime statistics;
- achievements;
- Daily Challenge history;
- Undo history;
- account/analytics data, because the default app has no such system.

The application does not automatically upload or synchronize backup text.

Clipboard data is managed by the operating system/platform, so users should treat a copied backup like other clipboard content. A backup is not encrypted or signed. Do not share it unless you intend to share the embedded current-game state.

Import reads clipboard text only after the user activates **Import from clipboard**. The text is strictly validated and requires explicit confirmation before replacing the current game.

Every imported game is marked locally as unranked. Imported play cannot update trusted lifetime statistics, achievements, streaks, or Daily history. This policy prevents user-editable portable data from becoming trusted record data.

See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## Move Replay

Move Replay does not create a new tracking/history database. It reads the existing validated current game and bounded Undo history, builds defensive in-memory copies, and displays them as a spectator timeline. Viewing, scrubbing, or playing Replay does not modify the live game, statistics, achievements, Daily Challenge history, or RNG state.

Because Undo history is bounded, replay history is also bounded. No replay timeline is uploaded or synchronized.

## Auto Play Demo

Auto Play Demo uses an isolated in-memory deterministic sandbox. It has no persistence key and does not write player saves, statistics, achievements, or Daily Challenge history. Closing the demo screen discards its sandbox state.

The current demonstration uses local game logic only; it does not contact an AI service, download a model, or send board state to a server.

## Daily Challenge

Daily Challenge is generated locally from a UTC date-derived seed. The app does not need to contact a server to obtain the day's seed or submit a result. Recent Daily records are local-only in the default build.

Daily mode is intentionally excluded from Challenge Codes, so arbitrary shared-code text cannot masquerade as a date-derived Daily entry.

## Hint solver

Hints are evaluated locally using copied board values and a deterministic heuristic. No board state is sent to an external AI/model endpoint.

## External destinations

External destinations such as GitHub, LinkedIn, email, and Buy Me a Coffee require network access or platform handlers only when explicitly opened by the user. Supported destinations are handed off through the project's validated `https`/`mailto` policy.

If launch fails, the app can offer a copy fallback. It does not silently replace a failed secure destination with an arbitrary insecure scheme.

## Sound and haptics

Sound and haptic settings control local platform feedback. The project does not use them as telemetry signals.

## Logs and automated builds

The repository's GitHub Actions workflows compile and test source code. Project policy is to avoid committing or printing credentials/private signing material. Real Android/iOS distribution signing should use private platform/store practices outside public source control.

## Third-party packages

Runtime package use beyond Flutter is intentionally limited to:

- `shared_preferences` for small local project state;
- `url_launcher` for explicit external browser/email handoff.

Challenge Codes use Dart JSON/Base64URL and Flutter's clipboard APIs through the local `TextClipboard` abstraction, so they add no third-party runtime package or network dependency.

The project does not currently include an analytics, advertising, crash-reporting, account, cloud-storage, or remote-AI runtime SDK.

See [`DEPENDENCIES.md`](DEPENDENCIES.md).

## Distribution note

Store privacy/data-safety declarations must be reviewed against the **exact release build and store configuration** before publication. The repository's offline-first design does not replace Google Play, Apple App Store, Microsoft Store, or other platform-specific disclosure requirements.

If future work adds analytics, ads, accounts, multiplayer/cloud synchronization, remote AI, push notifications, or another data-transmitting feature, this document and store disclosures must be updated before release.

## Localization privacy

Language switching is an offline local operation. 2048 Nova does not send UI strings, selected language, game text, clipboard contents, or user data to an online translation API. English and Hindi strings ship with the application.

Changing language does not alter or upload saved games, statistics, achievements, Daily history, Challenge Codes, Game Backup, Replay, or Auto Play data. The only network-capable actions remain explicit external browser/email/support destinations initiated by the player.


## Per-mode record privacy

Per-mode best score/highest-tile records are derived locally from trusted game sessions and stored inside the existing local statistics preference payload. They are not uploaded, synchronized, advertised, analyzed by telemetry, or attached to an account because 2048 Nova has no account/cloud analytics path.

The Statistics screen reads these values locally. Game Backup export continues to contain only the current game envelope defined by the backup feature; lifetime aggregate statistics and per-mode records are not exported with it. Imported backups remain unranked and cannot write these records.


## Advanced solver privacy boundary

Heuristic, bounded Expectimax, and the deterministic solver benchmark run entirely on local in-memory board state. They send no board, seed, score, decision, benchmark metric, or diagnostic to a project server or third party. No remote AI/model API is used.

Expectimax is available only through the isolated Auto Play sandbox. Its search-node count and expected-value calculation are transient diagnostics; they are not persisted as player data or analytics. The benchmark library/CLI creates fresh seeded sandbox sessions and writes no project preference key.

## Full Replay Archive privacy

Full Replay Archive records a bounded local action sequence for newly started sessions. The active capture stores the validated opening game state plus move, Undo, continue, and status events with elapsed action timing. It is local project data and is not uploaded, synchronized, analyzed, or sent to a remote AI service.

Selecting **Copy full replay** writes a complete archive to the system clipboard only after explicit user action. **Open from clipboard** reads clipboard text only after explicit action; manual text entry is also available. The app does not monitor the clipboard in the background. Platform clipboard history and synchronization are controlled by the operating system or browser.

A shared replay can reveal game configuration, seed and RNG state, opening board, move directions, timing, and reconstructed score and board evolution. The JSON is not encrypted or signed. Opening a replay is spectator-only and cannot import lifetime statistics, achievements, streaks, Daily history, settings, or per-mode records. Structural and deterministic validity is not proof of authorship.
