

## Phase 15 — Offline Shareable Seeded Challenge Codes

### Phase goal

Phase 15 implements the next release-candidate roadmap item: a completely offline way to share the deterministic **starting configuration** of a 2048 game without introducing accounts, cloud synchronization, a multiplayer backend, a new database, or a progress-import trust problem.

The feature deliberately shares only a supported `GameConfig` plus deterministic seed. It does **not** share a progressed board, score, move count, lifetime statistics, achievements, settings, Daily history, or Undo snapshots. This keeps Challenge Codes conceptually and technically separate from Phase 14 Game Backup.

The project remains **2048 Nova 0.9.0+1 release candidate**. Phase 15 does not promote the project to stable 1.0.0.

### Architecture and trust decision

Two portable-text features now exist, with intentionally different policies:

```text
Challenge Code
  -> fresh configuration + deterministic seed only
  -> normal local new-game path
  -> normal non-Daily statistics/achievement policy

Game Backup
  -> progressed current GameState
  -> explicit restore path
  -> always locally marked unranked
  -> cannot mutate trusted lifetime/Daily records
```

This distinction prevents a configuration-sharing convenience from becoming a second progress-import protocol and prevents user-editable progressed backup data from being treated as trusted records.

Daily Challenge is intentionally excluded from Challenge Codes. Daily already derives its shared deterministic seed from the UTC calendar date and owns a dedicated date-indexed local history contract. Arbitrary portable Daily seeds would blur that contract and could create confusing history semantics.

### Domain codec

Added:

```text
lib/domain/challenge_code.dart
```

Current portable format:

```text
NOVA1.<base64url-payload>.<8-hex-checksum>
```

Logical decoded payload:

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

Current constants/policy:

```text
format: 2048-nova-challenge
version: 1
prefix: NOVA1
maximum input length: 1024 characters
checksum: 32-bit FNV-1a over the encoded payload
seed range: 0..0x7fffffff
```

Supported modes:

- Classic;
- Quick;
- Extended;
- Challenge;
- Endless;
- Target;
- Time Challenge;
- Move Limit;
- Zen.

Daily Challenge is rejected explicitly.

The codec reuses `GameConfig.fromJson()` as the authoritative type/range validator instead of duplicating configuration bounds in a portable parser.

Decode validation rejects:

- empty text;
- text over 1024 characters before payload parsing;
- unsupported prefix;
- wrong segment count;
- empty payload;
- malformed/non-hex/eight-character checksum;
- checksum mismatch;
- invalid Base64URL;
- invalid UTF-8;
- invalid JSON/non-map payload;
- wrong format identifier;
- unsupported version;
- missing/non-map configuration;
- invalid `GameConfig` fields/types/ranges;
- missing deterministic seed;
- unsupported portable mode, including Daily.

The checksum is deliberately documented as **accidental corruption/typo detection only**. It is not encryption, a digital signature, authentication, identity proof, or an anti-cheat system. A technically capable person can construct another valid configuration/code; under the current local-only feature this does not let them import progress or trusted records.

### Deterministic game-start behavior

`ChallengeCode.withSeed()` copies a normal preset configuration with an explicit validated seed. Starting a decoded code uses the same normal engine path as a locally chosen new game:

```text
ChallengeCode.decode(text)
  -> validated seeded GameConfig
  -> recoverable-game replacement guard
  -> AppController.newGame(config)
  -> GameEngine(config: config).createGame()
  -> normal local save/statistics policy
```

For the same supported configuration and seed, the engine produces the same opening board and post-opening RNG state. If two players subsequently make the same valid move sequence from identical state, the deterministic spawn sequence stays aligned. Different moves can change board occupancy and naturally cause the paths to diverge.

A Time Challenge Code shares the deterministic configuration/seed, but each newly started game gets its own local `startedAt`; the code does not synchronize a wall-clock competition start time.

### Player-facing Challenge Codes workspace

Added:

```text
lib/features/challenge_codes/challenge_code_screen.dart
```

Registered route:

```text
/challenge-codes
```

Home now exposes a **Challenge Codes** card.

Create flow:

1. choose a supported mode;
2. for Target mode, choose 128/256/512/1024/2048/4096/8192/16384;
3. generate a fresh deterministic seed;
4. encode the seeded configuration;
5. display selectable `NOVA1...` text;
6. copy only after explicit user action.

Open flow:

1. paste or manually type code text;
2. validate explicitly, with Paste also validating after reading clipboard;
3. display mode, board size, target, move/time limit when present, and seed;
4. choose **Start this challenge**;
5. if a recoverable game exists, use the normal **Replace current game?** guard;
6. after confirmation, create a fresh normal local game and navigate to Game.

Invalid text cannot create or replace a game.

### Clipboard boundary

Challenge Codes reuse:

```text
lib/shared/text_clipboard.dart
```

Production defaults to `SystemTextClipboard`, which delegates to Flutter's system clipboard. The screen accepts an injected `TextClipboard` so widget tests use an in-memory deterministic implementation rather than a real platform channel.

The application reads/writes Challenge Code clipboard text only after explicit Paste/Copy actions. Manual entry remains available when platform clipboard behavior is unavailable or restricted.

No third-party sharing, QR, networking, or clipboard package was added.

### Persistence boundary

Challenge Codes add **no new SharedPreferences key**.

Generated and decoded code text lives only in screen memory and, after explicit actions, the system clipboard. Once a validated code is started, the resulting fresh `GameState` uses the existing normal current-game/Undo/statistics persistence path.

Because a Challenge Code cannot carry progressed state or claimed historical records, a game started from a code is not automatically unranked. It follows normal local non-Daily statistics/achievement behavior.

This differs intentionally from portable Game Backup, whose progressed user-editable state remains unranked.

### Source files changed/added

Production/in-app source:

```text
lib/domain/challenge_code.dart
lib/features/challenge_codes/challenge_code_screen.dart
lib/app/nova_app.dart
lib/features/home/home_screen.dart
lib/features/guide/guide_screen.dart
lib/features/about/about_screen.dart
```

Existing shared boundary reused:

```text
lib/shared/text_clipboard.dart
lib/shared/game_replacement_guard.dart
```

Automated coverage:

```text
test/challenge_code_test.dart
test/challenge_code_screen_test.dart
test/widget_smoke_test.dart
```

### Automated test expansion

Phase 14 ended at **112 tests**.

Phase 15 adds exactly **15** cases:

```text
test/challenge_code_test.dart        10
test/challenge_code_screen_test.dart  4
test/widget_smoke_test.dart            1 new Challenge Codes navigation case
                                      --
Total added                             15
Final suite                            127
```

Pure codec/determinism coverage verifies:

- every supported preset mode round-trips after adding a seed;
- encoding is stable for the same configuration;
- decoded configuration reproduces the same opening board/RNG state;
- unseeded configuration rejection;
- Daily rejection;
- empty/unsupported-prefix rejection;
- checksum-tampering rejection;
- malformed checksum/payload-shape rejection;
- pre-parse oversized input rejection;
- unsafe seed-bound rejection.

Widget/state-flow coverage verifies:

- deterministic generated code and Copy action;
- Paste/Validate of a valid code;
- decoded preview visibility;
- starting a code produces the exact decoded configuration and deterministic opening state;
- invalid input preserves the no-game state;
- cancelling recoverable-game replacement leaves the existing ranked game unchanged;
- Home navigation opens the Challenge Codes workspace.

### Transparent implementation defect and correction

The first `ChallengeCode` codec commit attempted to rebuild Base64URL padding with unsupported Dart string multiplication. The defect was corrected immediately before final verification.

Correcting commit:

```text
88c2954f9703a72626ddf47d93b4d6e9e8e8dfeb
fix: decode challenge code padding with valid Dart
```

The final implementation uses:

```text
List.filled(paddingCount, '=').join()
```

This intermediate coding defect is recorded rather than rewritten out of the project history.

### Final maintained quality gate

```text
Workflow: CI
Run: 31796242355
Verified commit: 643b38665738ce314eea81e3dcc8887c77fb2257
Commit: docs: explain challenge code deterministic engine relationship
Flutter: 3.47.0 stable
Dart: 3.13.0
Overall: SUCCESS
```

Results:

- dependency resolution: **PASS**;
- Dart formatting: **PASS — 66 files, 0 changed**;
- Flutter static analysis: **PASS — No issues found**;
- automated tests: **PASS — 127/127**;
- Flutter Web release build: **PASS — build/web**;
- WASM dry run: **PASS**.

The CI log retains the existing non-blocking package-update availability notices, CupertinoIcons lookup warning during the successful Web build, and hosted Actions Node runtime deprecation notice. None caused a failed quality gate.

Earlier Phase 15 CI run `31795076552` passed formatter, analyzer, and tests for an earlier source state but had its Web step cancelled when a newer commit superseded it through the repository concurrency policy. It is **not** treated as a code failure and is not promoted as final evidence. Complete run `31796242355` supersedes it.

### Final native production gate

```text
Workflow: Platform Builds
Run: 31795329370
Verified production/in-app-doc commit: 7c83d7a14656d9309b54205de1f72e0af131f551
Commit: docs: include challenge codes in app release highlights
Overall: SUCCESS
```

Jobs:

```text
Windows job:               94751062446 — PASS
Android release APK job:   94751062458 — PASS
macOS + unsigned iOS job:  94751062524 — PASS
Linux job:                 94751062579 — PASS
```

Configured targets:

- Android release APK — **PASS**;
- Linux release — **PASS**;
- Windows release — **PASS**;
- macOS release — **PASS**;
- iOS release with `--no-codesign` — **PASS**.

That commit contains all Phase 15 runtime source plus the compiled in-app Guide/About Challenge Code documentation. Later Phase 15 commits before final CI were tests and repository documentation only.

### Documentation completed in Phase 15

Added:

```text
docs/CHALLENGE_CODES.md
```

Updated Challenge Code behavior/trust/platform/release guidance across:

```text
README.md
docs/README.md
docs/USER_GUIDE.md
docs/FAQ.md
docs/ARCHITECTURE.md
docs/GAME_ENGINE.md
docs/GAME_MODES.md
docs/DATA_STORAGE.md
docs/BACKUP_AND_RESTORE.md
docs/PRIVACY.md
docs/ACCESSIBILITY.md
docs/DEPENDENCIES.md
docs/DEVELOPMENT.md
docs/TROUBLESHOOTING.md
docs/PLATFORMS.md
docs/CI_CD.md
docs/TESTING.md
docs/VERIFICATION.md
docs/RELEASE_CHECKLIST.md
CONTRIBUTING.md
SECURITY.md
SUPPORT.md
ROADMAP.md
CHANGELOG.md
what_changed.md
```

The documentation explicitly distinguishes:

- configuration-sharing Challenge Codes from progressed Game Backup;
- normal fresh-game record policy from unranked imported progress;
- checksum corruption detection from real cryptographic authentication;
- configured/native compilation from real clipboard/device/accessibility qualification;
- automated 127-test evidence from remaining manual release work.

### Key Phase 15 commits

```text
e5d63ef9a46423bd9aabcd4bf4eab70d3be38395  feat: add versioned seeded challenge code codec
88c2954f9703a72626ddf47d93b4d6e9e8e8dfeb  fix: decode challenge code padding with valid Dart
0daa054160dafb7140b8a0cfbf47237f40f82afd  test: cover seeded challenge code validation
5b416d1d1185d556794b2d6bc245d90c521cd5e3  feat: add shareable challenge code screen
2f00b8678ec085dae26d5cc25a62dcee11d4ba0b  feat: register challenge code route
fbd653cefd30cf039140cabab87d30533ebf7cf5  feat: expose challenge codes from home
531b11287dc38cb328702c1e3a22e6787f64db3d  test: cover challenge code UI flows
d6b293ecdc3f0fb519f365bfca51fef95902b457  test: cover challenge code navigation from home
8c034b69b79e4e7d0bba9a11c48cdea27e592f4a  docs: explain challenge codes in the in-app guide
7c83d7a14656d9309b54205de1f72e0af131f551  docs: include challenge codes in app release highlights
a77f8d607a387dab182f5a204347caccc92929d9  docs: add seeded challenge code specification
643b38665738ce314eea81e3dcc8887c77fb2257  docs: explain challenge code deterministic engine relationship
72fbfc2c81892dc75b347ea6b4e3fe119fc682d8  docs: record Phase 15 challenge code verification
60149f7acc8dbc031c1b2405e6f74fb3b513b6fc  docs: record Phase 15 challenge code test coverage
2e4100538259bf41b15673a92b2f48c94c5ab1ee  docs: record Phase 15 seeded challenge codes
```

Additional Phase 15 documentation commits remain in the normal repository history; no empty/no-op commits were added to inflate commit count.

Direct repository and automation commits use:

```text
Sanskar <sanskarin@outlook.in>
```

### Historical correction

A Phase 14 addendum contained a shortened/incorrect commit text `137180a1...` for the final Backup widget scroll fix. The correct commit is:

```text
1371ef9eaa00f1da5a2ce0370a1f22eb1f2f4cd2
test: scroll backup page beyond bottom navigation before taps
```

`docs/TESTING.md`, `docs/VERIFICATION.md`, and the current `CHANGELOG.md` use the corrected SHA. This correction does not change the Phase 14 verification result: CI run `31787639781` passed 112/112 tests and the Web release build.

### Development-log helper transparency

The first Phase 15 log helper run `31796719195` failed at workflow parsing because the multiline append payload was not encoded safely for YAML. It ran no project job and changed no source/log content.

A second attempt (`31797028878`) also failed at workflow parsing when the encoded payload was embedded as very long environment-value lines. It likewise ran no project job and changed no source/log content.

The final helper stages this Markdown payload as a temporary repository file, appends it with normal shell `cat`, commits `what_changed.md`, removes both temporary files in that same commit, rebases normally, and pushes without force.

### Permanent workflow state

Phase 15 required no feature diagnostic/patch workflow. The self-removing log helper and its temporary payload are deleted in the same commit that appends this section.

The intended permanent workflow set after this commit is:

```text
bootstrap-branding.yml
bootstrap-platforms.yml
ci.yml
format-code.yml
lock-dependencies.yml
platform-builds.yml
```

### Remaining manual boundaries before stable 1.0.0

Still required before a truthful stable release:

- representative physical Android/iOS gameplay/lifecycle/save-resume;
- touch/swipe thresholds and orientation/responsive behavior;
- real desktop/browser keyboard focus/shortcut behavior;
- TalkBack, VoiceOver, Narrator/browser screen-reader qualification;
- Challenge Code generation/copy/paste/manual entry/validation/error/preview/replacement behavior using real platform clipboard handlers;
- same-code deterministic opening and same-valid-move-sequence comparisons across independent devices/runs;
- Challenge Code Target/Time/Move Limit/board-size/Endless/Zen qualification;
- confirmation on real builds that arbitrary Daily Challenge Codes remain unavailable and normal UTC-date Daily history is unchanged;
- Game Backup real clipboard/import/unranked/restart/Undo/multiple-mode checks;
- Move Replay/Auto Play long-session, pause/navigation-away, and accessibility checks;
- real browser/email external handlers;
- native splash/icon visual review;
- Android production signing/store packaging;
- Apple signing/provisioning/notarization as applicable;
- final store privacy/data-safety/listing/package review.

Automated success does not prove universal absence of defects. The project remains:

```text
Project: 2048 Nova
Version: 0.9.0+1
Status: release candidate
Stable 1.0.0: NOT YET
```
