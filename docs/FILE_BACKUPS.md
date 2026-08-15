# File-Based Game Backup

Phase 20 extends the existing portable current-game **Game Backup** with explicit user-selected file transport. The file feature does not create a second backup schema and does not change the imported-game trust model.

## Format

A saved `.nova2048` file contains the exact same versioned JSON envelope produced by `GameBackup.encode()` for clipboard export:

```text
format: 2048-nova-game-backup
version: 1
```

The payload contains one validated current `GameState` plus the export timestamp. Settings, lifetime statistics, achievements, Daily Challenge history, per-mode records, and old Undo history are intentionally excluded.

The file chooser accepts `.nova2048` and `.json` as convenience filters. The extension and filename are **not** security or authenticity signals. `GameBackup.decode()` remains the authoritative content validator.

## Export flow

Game Backup exposes **Save backup file** when a current game exists.

1. The current game is encoded with the existing `GameBackup` codec.
2. The app proposes a UTC-stamped filename such as `2048-nova-game-backup-2026-08-15T08-30-00.000Z.nova2048`.
3. The platform/browser file-save UI is opened through `file_picker`.
4. The encoded UTF-8 bytes are written only after that explicit user action.
5. Cancellation is handled as a normal non-destructive outcome.

On Web, the browser owns the download destination and may not return a filesystem path. A completed browser save/download handoff is therefore treated as a successful export without relying on a native path.

## Import flow

Game Backup exposes **Import backup file**.

1. The platform/browser picker is opened only after the user activates the action.
2. Only one file is requested.
3. The reported byte length is checked before reading the complete file.
4. The actual byte length is checked again after reading.
5. Bytes must decode as strict UTF-8.
6. `GameBackup.decode()` then applies the existing text-length, JSON envelope, format/version, timestamp, and strict `GameState` validation.
7. A decoded preview is shown.
8. The current game is replaced only after explicit confirmation.
9. The restored session is persistently marked **unranked** through the same controller path used by clipboard backup import.

File import never bypasses `AppController.importGameBackup()` and never receives a separate ranked path.

## Input bounds

`GameBackup.maxEncodedLength` remains `128 * 1024` characters for the validated JSON text protocol.

File transport adds:

```text
GameBackup.maxFileBytes = GameBackup.maxEncodedLength * 4
                        = 524,288 bytes
```

UTF-8 can require up to four bytes for a Unicode scalar value. The file boundary therefore rejects files larger than 512 KiB before full text decoding and then applies the existing 128 Ki-character protocol limit after UTF-8 conversion.

Normal 2048 Nova current-game backups are far smaller than these safety ceilings.

## Trust boundary

A `.nova2048` file is user-editable portable data. It is not:

- encrypted;
- digitally signed;
- authenticated;
- proof of player identity;
- proof of score legitimacy;
- an anti-cheat record;
- trusted merely because the extension is `.nova2048`.

All imported backup sessions remain unranked after restart and cannot update trusted lifetime statistics, achievements, streaks, Daily results, global best score, or per-mode records.

The imported session can still be played, saved, and receive new Undo snapshots for its own local continuation.

## File access model

The application does not scan directories or monitor files in the background. File access begins only when the player chooses **Save backup file** or **Import backup file**.

`SystemGameBackupFilePort` is the production boundary around `file_picker`. `GameBackupScreen` depends on the `GameBackupFilePort` interface so widget tests can use an in-memory fake without invoking platform channels.

The production implementation:

- uses user-selected save/open dialogs;
- asks for one file only;
- filters to `.nova2048` / `.json` where supported;
- obtains bytes in memory on Web;
- defers native file reading until after the picker-reported size check where possible;
- performs no network upload or synchronization.

## macOS sandbox

The macOS Debug/Profile and Release entitlements include:

```text
com.apple.security.files.user-selected.read-write = true
```

This grants sandbox access only to files the user selects through the platform interaction. It is not broad filesystem permission.

## Dependency

Phase 20 adds the pinned runtime dependency:

```text
file_picker 11.0.2
```

It is used only for explicit user-selected backup save/open transport. The game backup codec, ranking policy, and validation remain project-owned code.

## Platform behavior

The configured file transport is intended for Android, iOS, Web, Windows, macOS, and Linux. Browser and native picker presentations differ because the operating system/browser owns the chooser UI.

Hosted compilation verifies plugin integration, but final release qualification still requires representative real-environment save/open checks on each intended target.

## Automated coverage

Phase 20 widget/localization coverage verifies:

- file export produces a decodable Game Backup;
- suggested filenames use `.nova2048`;
- cancelled export leaves the game unchanged;
- valid file import uses the same explicit unranked confirmation path;
- cancelled file selection leaves the ranked current game unchanged;
- oversized-file rejection occurs before restore confirmation;
- file actions and error messages have Hindi catalog coverage;
- existing clipboard backup behavior remains covered.

The system picker itself remains a platform/plugin boundary and is therefore additionally covered by Web/native compilation plus manual release qualification.

## Manual release checks

Before stable `1.0.0`, verify on representative real targets:

- Save/Save As presentation and cancellation;
- `.nova2048` round trip into a fresh app session;
- import from `.json` where the picker exposes the filter;
- overwrite behavior where supported;
- Web download and browser file-open behavior;
- Android/iOS document-provider behavior, including user-selected cloud-backed files where applicable;
- macOS sandbox access with the user-selected read/write entitlement;
- Windows/Linux native picker behavior;
- malformed, non-UTF-8, oversized, and unsupported-version rejection;
- large-but-valid backup responsiveness;
- Hindi, large text, keyboard/focus, VoiceOver/TalkBack/Narrator/browser-screen-reader behavior for the new actions and feedback.

These checks are manual release boundaries and are not implied by hosted compilation.

## Related documentation

- [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md)
- [`DATA_STORAGE.md`](DATA_STORAGE.md)
- [`PRIVACY.md`](PRIVACY.md)
- [`DEPENDENCIES.md`](DEPENDENCIES.md)
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)
- [`VERIFICATION.md`](VERIFICATION.md)
