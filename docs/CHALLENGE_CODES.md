# Shareable Seeded Challenge Codes

2048 Nova supports offline, text-based challenge codes for starting the same deterministic game configuration on another device or in another session. Challenge codes require no account, server, cloud synchronization, analytics service, or network connection.

## Purpose

A challenge code answers one narrow question: **how can two players start the same configured 2048 opening?**

The code contains only:

- challenge-code format identifier;
- challenge-code schema version;
- game mode;
- board size;
- target tile;
- optional move limit;
- optional time limit;
- deterministic random seed.

It does **not** contain:

- a current board position;
- score or move progress;
- lifetime best score;
- statistics;
- achievements;
- streaks;
- Daily Challenge history;
- Undo history;
- settings;
- account/profile data.

Portable current-game progress remains a separate feature documented in [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## Supported modes

Challenge codes support:

- Classic;
- Quick;
- Extended;
- Challenge;
- Endless;
- Target;
- Time Challenge;
- Move Limit;
- Zen.

**Daily Challenge is intentionally excluded.** Daily Challenge already derives its deterministic seed from the UTC date and maintains dedicated date-based local history. Allowing arbitrary imported Daily seeds would blur that separate history contract.

## User workflow

Open **Home → Challenge Codes**.

### Create a code

1. Choose a supported mode.
2. For Target mode, choose the target tile.
3. Select **Generate new seeded code**.
4. Review the generated `NOVA1...` code.
5. Select **Copy challenge code**.
6. Share the text through any channel you choose.

Each generation creates a fresh deterministic seed. Generating a new code does not create or replace a game until a code is explicitly started.

### Open a code

1. Paste or type a challenge code into the input field.
2. Select **Validate code**, or use **Paste code** to read the clipboard and validate immediately.
3. Review the decoded mode, board, target, limits, and seed.
4. Select **Start this challenge**.
5. If another recoverable game exists, explicitly confirm replacement before the new game is created.

Starting a valid code creates a **fresh game** from that configuration. It does not restore somebody else's progress.

## Deterministic behavior

The game engine uses `SeededRandomSource` when a configuration supplies a seed. Therefore the same supported configuration and seed produce the same initial tile placement/value sequence and the same future spawn sequence when the same valid move sequence is made.

The challenge-code test suite verifies that encoding/decoding preserves the complete configuration and that two engines built from the original and decoded configuration produce the same opening board and RNG state.

Determinism does not mean two players will always have the same board after play starts. If they make different valid moves, their future states diverge because the board-dependent spawn positions and subsequent move sequence differ.

## Code format

The human-facing representation is:

```text
NOVA1.<base64url-payload>.<8-hex-checksum>
```

The decoded payload is JSON with this logical structure:

```json
{
  "format": "2048-nova-challenge",
  "version": 1,
  "config": {
    "mode": "classic",
    "size": 4,
    "target": 2048,
    "moveLimit": null,
    "timeLimitSeconds": null,
    "seed": 123456789
  }
}
```

The encoded payload removes Base64URL padding characters to keep the copied form shorter. The decoder restores required padding internally.

## Validation

`ChallengeCode.decode` treats code text as untrusted input and validates it before a game can be started.

Current checks include:

- empty-input rejection;
- maximum code length of 1024 characters before payload parsing;
- exact `NOVA1` prefix;
- exactly three code segments;
- non-empty payload;
- exactly eight hexadecimal checksum characters;
- checksum match;
- valid Base64URL and UTF-8 payload;
- valid JSON object;
- exact format identifier;
- supported schema version;
- required game configuration object;
- strict `GameConfig.fromJson` validation;
- deterministic seed requirement;
- seed range validation;
- supported-mode allowlist;
- explicit Daily-mode rejection.

The configuration parser remains the source of truth for board-size, target, move-limit, time-limit, game-mode, and seed bounds.

## Checksum and trust model

The checksum is 32-bit FNV-1a over the encoded payload. It is intended to detect accidental corruption or editing mistakes.

It is **not**:

- encryption;
- a digital signature;
- proof of identity;
- proof that a specific person created the code;
- an anti-cheat mechanism.

Challenge codes are deliberately plain shareable text. A technically capable person can create a different valid configuration/code. This is acceptable because challenge codes start a fresh configuration only; they do not import score, board progress, achievements, statistics, or Daily records.

## Ranking/statistics policy

A valid challenge code starts a new non-Daily game through the normal `AppController.newGame` path. It therefore behaves like another locally started game and participates in normal local statistics/achievements.

This differs from **Game Backup**. Backup restores editable progress and is therefore always marked unranked. A challenge code contains no progress or claimed historical record; it only chooses the deterministic configuration of a fresh game.

If the project later introduces a competitive online leaderboard or authenticated tournament system, this local-only policy must be reviewed rather than silently assumed to provide server-grade competitive integrity.

## Privacy

2048 Nova does not send challenge codes anywhere automatically. The code exists in application memory and reaches the system clipboard only after an explicit **Copy challenge code** action. Pasting reads clipboard text only after the player selects **Paste code**.

After a challenge is started, the normal local save system stores the resulting game state. See [`DATA_STORAGE.md`](DATA_STORAGE.md) and [`PRIVACY.md`](PRIVACY.md).

## Accessibility

The Challenge Codes screen uses normal Flutter form controls, visible text labels, scrollable content, explicit validation feedback, selectable generated code text, and a structured decoded preview. Stable release qualification should still test the real screen with TalkBack, VoiceOver, Narrator/browser screen readers, large text, keyboard focus, and actual platform clipboard handlers.

## Source files

Primary implementation:

```text
lib/domain/challenge_code.dart
lib/features/challenge_codes/challenge_code_screen.dart
lib/shared/text_clipboard.dart
lib/shared/game_replacement_guard.dart
lib/app/nova_app.dart
lib/features/home/home_screen.dart
```

Primary automated coverage:

```text
test/challenge_code_test.dart
test/challenge_code_screen_test.dart
```

## Future compatibility

The current schema version is `1`. A future incompatible format must increment its version and add an explicit migration/compatibility decision. Unsupported versions fail closed rather than being interpreted as the current schema.

The current code format is intentionally separate from the Game Backup JSON format. The two features solve different problems and should not be merged merely because both are portable text.
