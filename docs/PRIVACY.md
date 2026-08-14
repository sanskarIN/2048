# Privacy

2048 Nova is designed as an offline-first game. The default codebase does not add analytics, advertising trackers, accounts, cloud synchronization, remote AI services, or background telemetry.

## Local project data

The application stores project-owned game data locally through Flutter's SharedPreferences abstraction, including:

- current saved game state;
- bounded Undo snapshots;
- settings;
- lifetime statistics;
- achievement unlock timestamps;
- bounded Daily Challenge history.

Saved structures are validated before use. Malformed current-game data fails safely, while bounded Undo/Daily collections retain valid neighboring records when repair is possible.

## Move Replay

Move Replay does not create a new tracking/history database. It reads the existing validated current game and bounded Undo history, builds defensive in-memory copies, and displays them as a spectator timeline. Viewing, scrubbing, or playing Replay does not modify the live game, statistics, achievements, Daily Challenge history, or RNG state.

Because Undo history is bounded, replay history is also bounded. No replay timeline is uploaded or synchronized.

## Auto Play Demo

Auto Play Demo uses an isolated in-memory deterministic sandbox. It has no persistence key and does not write player saves, statistics, achievements, or Daily Challenge history. Closing the demo screen discards its sandbox state.

The current demonstration uses local game logic only; it does not contact an AI service, download a model, or send board state to a server.

## External destinations

External destinations such as GitHub, LinkedIn, email, and Buy Me a Coffee require network access or platform handlers only when explicitly opened by the user. Supported destinations are handed off through the project's validated `https`/`mailto` policy.

## Distribution note

Store privacy/data-safety declarations should be reviewed against the exact release build before publication. The repository's offline-first design does not replace store-specific disclosure requirements.
