from pathlib import Path
import subprocess


def commit_file(path: str, message: str) -> None:
    subprocess.run(["git", "add", path], check=True)
    result = subprocess.run(["git", "diff", "--cached", "--quiet"])
    if result.returncode != 0:
        subprocess.run(["git", "commit", "-m", message], check=True)


def replace(path: str, old: str, new: str, message: str) -> None:
    p = Path(path)
    text = p.read_text()
    if new in text:
        return
    if old not in text:
        raise RuntimeError(f"anchor not found in {path}: {old[:80]!r}")
    p.write_text(text.replace(old, new, 1))
    commit_file(path, message)


def append(path: str, marker: str, block: str, message: str) -> None:
    p = Path(path)
    text = p.read_text()
    if marker in text:
        return
    p.write_text(text.rstrip() + "\n\n" + block.strip() + "\n")
    commit_file(path, message)


replace(
    "README.md",
    "- **Game Backup** for copying/restoring one current game as validated JSON through the clipboard.",
    "- **Game Backup** for copying/restoring one current game as validated JSON through the clipboard or explicit user-selected `.nova2048` / `.json` files, with byte-bounded file reads before UTF-8/JSON validation.",
    "docs: describe file backup in project features",
)
replace(
    "README.md",
    "| Backup and restore | [`docs/BACKUP_AND_RESTORE.md`](docs/BACKUP_AND_RESTORE.md) |",
    "| Backup and restore | [`docs/BACKUP_AND_RESTORE.md`](docs/BACKUP_AND_RESTORE.md) |\n| File backup transport | [`docs/FILE_BACKUPS.md`](docs/FILE_BACKUPS.md) |",
    "docs: link file backup transport from README",
)
replace(
    "README.md",
    "Home exposes **Game Backup**. Export copies a versioned JSON envelope for the current game to the clipboard. It intentionally excludes settings, lifetime statistics, achievements, Daily history, and Undo history.\n\nImport is an untrusted-input boundary. The app checks maximum text size, JSON structure, format/version, timestamp, and strict embedded `GameState` validity, then requires explicit confirmation before replacement.",
    "Home exposes **Game Backup**. Export can copy a versioned JSON envelope for the current game to the clipboard or save the same envelope through an explicit user-selected `.nova2048` file. It intentionally excludes settings, lifetime statistics, achievements, Daily history, per-mode records, and old Undo history.\n\nImport from clipboard or file is an untrusted-input boundary. File input is byte-bounded before strict UTF-8 decode; both transports then share the same maximum text-size, JSON structure, format/version, timestamp, strict embedded `GameState`, explicit confirmation, and persistent unranked policy.",
    "docs: update README backup workflow",
)
replace(
    "README.md",
    "- `shared_preferences` — small local game/settings/statistics storage.\n- `url_launcher` — safe handoff to browser/email handlers for explicit external actions.",
    "- `file_picker` — explicit user-selected Game Backup file save/open transport across configured Flutter targets.\n- `shared_preferences` — small local game/settings/statistics storage.\n- `url_launcher` — safe handoff to browser/email handlers for explicit external actions.",
    "docs: declare file picker runtime dependency",
)
replace(
    "README.md",
    "Challenge Codes use Dart JSON/Base64URL and the existing Flutter clipboard abstraction. Game Backup uses Dart JSON and Flutter clipboard APIs. Move Replay and Auto Play Demo add no network service, model download, or third-party AI dependency.",
    "Challenge Codes use Dart JSON/Base64URL and the existing Flutter clipboard abstraction. Game Backup keeps its project-owned JSON codec and clipboard path and uses pinned `file_picker 11.0.2` only for explicit user-selected file transport. Move Replay and Auto Play Demo add no network service, model download, or third-party AI dependency.",
    "docs: clarify backup dependency boundary",
)

replace(
    "ROADMAP.md",
    "- Versioned **Game Backup** for copying/restoring one current game through the clipboard with strict input validation, explicit replacement confirmation, Undo isolation, and persistent unranked-import policy.",
    "- Versioned **Game Backup** for copying/restoring one current game through the clipboard or explicit user-selected `.nova2048` / `.json` files, with pre-decode file-size bounds, strict shared validation, explicit replacement confirmation, Undo isolation, and persistent unranked-import policy.",
    "docs: mark file backup complete on roadmap",
)
replace(
    "ROADMAP.md",
    "- Real-platform Game Backup copy/import/cancel/restore/restart/Undo checks using actual clipboard handlers.",
    "- Real-platform Game Backup clipboard copy/import plus file Save/Open/cancel/round-trip/oversize/non-UTF-8/restore/restart/Undo checks using actual clipboard, browser download/file-input, native picker, document-provider, and macOS sandbox handlers.",
    "docs: expand Game Backup release qualification",
)
replace(
    "ROADMAP.md",
    "- Optional file-based backup import/export in addition to the implemented clipboard backup, with the same strict validation/unranked policy.\n",
    "",
    "docs: remove completed file backup roadmap item",
)

replace(
    "docs/BACKUP_AND_RESTORE.md",
    "2048 Nova supports a portable, clipboard-based backup for the **current game only**. The feature is deliberately narrow: it lets a player carry or preserve one game state without importing lifetime records or treating externally supplied data as trusted ranked progress.",
    "2048 Nova supports a portable backup for the **current game only** through either the clipboard or an explicit user-selected `.nova2048` / `.json` file. Both transports carry the same versioned JSON envelope. The feature is deliberately narrow: it lets a player carry or preserve one game state without importing lifetime records or treating externally supplied data as trusted ranked progress.",
    "docs: update Game Backup transport overview",
)
replace(
    "docs/BACKUP_AND_RESTORE.md",
    "From Home, open **Game Backup** and select **Copy game backup**. When a current game exists, the application:\n\n1. encodes that game with `GameBackup.encode()`;\n2. writes the JSON text to the system clipboard;\n3. leaves the live player game unchanged;\n4. shows a confirmation message.\n\nThere is no file-system permission requirement and no extra package dependency for this workflow; it uses Flutter's clipboard API and Dart JSON encoding.",
    "From Home, open **Game Backup**. A current game can be exported in either of two ways:\n\n- **Copy game backup** encodes with `GameBackup.encode()` and writes the JSON text to the system clipboard.\n- **Save backup file** encodes the same envelope to UTF-8 bytes and opens the explicit user-selected save flow through the file transport abstraction, proposing a UTC-stamped `.nova2048` filename.\n\nBoth flows leave the live player game unchanged. Cancelling a native Save dialog is a normal non-destructive outcome. On Web, the browser owns the download destination and the app does not require a returned filesystem path to treat the explicit download handoff as successful.",
    "docs: document clipboard and file backup export",
)
replace(
    "docs/BACKUP_AND_RESTORE.md",
    "Select **Import from clipboard**. The application:\n\n1. reads plain text from the clipboard;\n2. rejects missing or empty text;\n3. checks the maximum encoded length before JSON parsing;\n4. parses the envelope as JSON;\n5. validates the backup format and version;\n6. validates the export timestamp;\n7. requires an embedded game object;\n8. passes the embedded object through strict `GameState.fromJson()` validation;\n9. displays a non-dismissible preview/confirmation dialog;\n10. restores only after the player explicitly chooses **Restore unranked backup**.\n\nCancelling the dialog leaves the current ranked game untouched.",
    "Select **Import from clipboard** or **Import backup file**. Clipboard import reads text only after the explicit action. File import opens one user-selected `.nova2048` / `.json` file, rejects an oversized reported or actual byte length before full text processing, and requires strict UTF-8. Both transports then converge on the same flow:\n\n1. reject missing/empty or invalid input;\n2. check the maximum encoded text length before JSON parsing;\n3. parse the envelope as JSON;\n4. validate backup format and version;\n5. validate export timestamp;\n6. require an embedded game object;\n7. pass the embedded object through strict `GameState.fromJson()` validation;\n8. display a non-dismissible preview/confirmation dialog;\n9. restore only after the player explicitly chooses **Restore unranked backup**.\n\nCancelling the picker or confirmation leaves the current ranked game untouched.",
    "docs: document shared Game Backup import path",
)
replace(
    "docs/BACKUP_AND_RESTORE.md",
    "format = 2048-nova-game-backup\nversion = 1\nmaxEncodedLength = 128 KiB",
    "format = 2048-nova-game-backup\nversion = 1\nmaxEncodedLength = 128 KiB\nmaxFileBytes = 512 KiB",
    "docs: record Game Backup file size bound",
)
replace(
    "docs/BACKUP_AND_RESTORE.md",
    "The size check happens before JSON parsing so unexpectedly large clipboard content is refused early.",
    "The encoded-text size check happens before JSON parsing. File import adds a 512 KiB byte ceiling before UTF-8 conversion and checks the actual loaded byte length again before the existing 128 Ki-character protocol limit is applied. The filename and extension never bypass content validation.",
    "docs: explain layered backup size validation",
)
append(
    "docs/BACKUP_AND_RESTORE.md",
    "## Phase 20 file transport",
    """## Phase 20 file transport

Phase 20 adds `GameBackupFilePort` under `lib/shared/`. Production uses `SystemGameBackupFilePort` backed by pinned `file_picker 11.0.2`; tests inject an in-memory fake. The port is transport-only: it never parses a game and never decides ranking. All accepted text still passes through `GameBackup.decode()`, and all state installation still passes through `AppController.importGameBackup()`.

The macOS sandbox enables `com.apple.security.files.user-selected.read-write` in Debug/Profile and Release entitlements. This is scoped to user-selected files rather than general directory scanning. See [`FILE_BACKUPS.md`](FILE_BACKUPS.md) for the complete transport contract and manual platform checks.
""",
    "docs: add Phase 20 backup transport contract",
)

append(
    "docs/ARCHITECTURE.md",
    "## Phase 20 file transport boundary",
    """## Phase 20 file transport boundary

File-based Game Backup keeps transport separate from validation and trusted-state policy:

```text
GameBackupScreen
  -> GameBackupFilePort
       -> SystemGameBackupFilePort / file_picker
  -> GameBackup.decode
  -> explicit restore preview
  -> AppController.importGameBackup
  -> LocalStore current game + persistent unranked marker
```

`GameBackupFilePort` owns only explicit user-selected text file read/write. It cannot rank an imported game. The domain `GameBackup` codec remains independent of the plugin, and `AppController` remains the single trust boundary that installs portable progress as unranked. This separation lets widget tests use an in-memory file port without invoking native platform channels.
""",
    "docs: document file backup architecture",
)
append(
    "docs/DATA_STORAGE.md",
    "## Phase 20 file backup storage boundary",
    """## Phase 20 file backup storage boundary

Saving or opening a `.nova2048` file does not add a new SharedPreferences key or a file-history database. Export writes the existing current-game backup envelope only to the explicit destination selected by the player. Import validates a selected file and then uses the existing current-game/unranked-marker persistence path.

The application does not retain source file paths, filenames, recent-file lists, cloud-provider metadata, or imported raw backup text after the restore flow. `GameBackup.maxFileBytes` is 512 KiB before UTF-8 decoding; the existing 128 Ki-character envelope limit is still applied afterward.
""",
    "docs: document file backup storage behavior",
)

replace(
    "docs/PRIVACY.md",
    "## Portable Game Backup and clipboard data",
    "## Portable Game Backup, clipboard, and selected files",
    "docs: broaden backup privacy section",
)
replace(
    "docs/PRIVACY.md",
    "Game Backup is an explicit user action. Export creates plain JSON text for the **current game only** and writes that text to the system clipboard.",
    "Game Backup is an explicit user action. Export creates plain JSON text for the **current game only** and can write that text to the system clipboard or to a `.nova2048` file selected through the platform/browser save flow.",
    "docs: document backup file privacy behavior",
)
replace(
    "docs/PRIVACY.md",
    "The application does not automatically upload or synchronize backup text.",
    "The application does not automatically upload or synchronize backup text and does not scan directories in the background. File access begins only after **Save backup file** or **Import backup file** is chosen. The operating system/browser may expose local or cloud-backed locations through its own picker; 2048 Nova receives only the user-selected file interaction and does not add a cloud-storage SDK.",
    "docs: clarify user-selected file privacy",
)
replace(
    "docs/PRIVACY.md",
    "Import reads clipboard text only after the user activates **Import from clipboard**. The text is strictly validated and requires explicit confirmation before replacing the current game.",
    "Import reads clipboard text only after **Import from clipboard**, or opens one selected file only after **Import backup file**. File bytes are bounded before UTF-8/JSON processing. Both transports use the same strict backup validation and require explicit confirmation before replacing the current game.",
    "docs: document file import privacy boundary",
)
replace(
    "docs/PRIVACY.md",
    "- `shared_preferences` for small local project state;\n- `url_launcher` for explicit external browser/email handoff.",
    "- `file_picker` for explicit user-selected Game Backup file save/open transport;\n- `shared_preferences` for small local project state;\n- `url_launcher` for explicit external browser/email handoff.",
    "docs: add file picker to privacy inventory",
)

replace(
    "SECURITY.md",
    "Clipboard backup text is untrusted input. The application checks:",
    "Clipboard text and user-selected backup files are untrusted input. File import first bounds the reported and actual byte length and requires strict UTF-8. The shared backup decoder then checks:",
    "docs: extend backup security boundary to files",
)
replace(
    "SECURITY.md",
    "Portable backup JSON is not encrypted, signed, or authenticated. Users should treat copied backup text as ordinary clipboard data and share it only intentionally.",
    "Portable backup JSON is not encrypted, signed, or authenticated. A `.nova2048` extension, filename, local path, or document-provider location is not proof of authenticity. Users should treat copied or saved backup data as editable portable game state and share it only intentionally.",
    "docs: clarify backup file authenticity boundary",
)
append(
    "SECURITY.md",
    "## File picker boundary",
    """## File picker boundary

Phase 20 pins `file_picker 11.0.2` for explicit Game Backup file selection/save transport. The plugin does not decide whether a backup is valid or ranked. The project applies size limits and UTF-8 decoding at `GameBackupFilePort`, domain validation at `GameBackup.decode()`, confirmation in the UI, and the permanent unranked policy in `AppController.importGameBackup()`.

macOS grants only `com.apple.security.files.user-selected.read-write` for files selected by the user. 2048 Nova does not intentionally enumerate arbitrary directories, retain recent-file paths, or add a cloud-storage/network SDK for backup transfer.
""",
    "docs: document file picker security boundary",
)

replace(
    "docs/DEPENDENCIES.md",
    "## Features that add no runtime package",
    "## file_picker\n\nPinned at **11.0.2** for Phase 20. It is used only by `SystemGameBackupFilePort` to open explicit user-selected save/open flows for Game Backup on the configured Flutter targets. The package does not own the backup schema, JSON validation, ranking policy, persistence, or networking.\n\nThe integration is wrapped behind the project-owned `GameBackupFilePort` interface so widget tests can inject a fake and domain code remains plugin-independent. File input is byte-bounded before strict UTF-8 decoding, then passed through the existing `GameBackup` validator.\n\nWhy it is used:\n\n- Flutter core does not expose one uniform cross-platform Save/Open document API for all configured targets;\n- the project needs Android/iOS/Web/Windows/macOS/Linux user-selected file transport;\n- it preserves explicit chooser interaction rather than adding broad filesystem scanning;\n- version 11.0.2 is pinned in `pubspec.yaml`/`pubspec.lock` for reproducible release-candidate builds.\n\nIt is not an analytics, cloud-storage, account, or networking dependency.\n\n## Features that add no additional runtime package",
    "docs: document file picker dependency",
)
replace(
    "docs/DEPENDENCIES.md",
    "Portable current-game backup uses:\n\n- `dart:convert` for JSON;\n- Flutter `Clipboard` / `ClipboardData` through `TextClipboard` for explicit copy/paste.\n\nNo file picker, cloud-storage SDK, encryption library, account service, or network package is required for the current clipboard-based feature.",
    "Portable current-game backup uses:\n\n- `dart:convert` for JSON/UTF-8;\n- Flutter `Clipboard` / `ClipboardData` through `TextClipboard` for explicit copy/paste;\n- the Phase 20 `GameBackupFilePort` wrapper around pinned `file_picker 11.0.2` for explicit user-selected save/open transport.\n\nNo cloud-storage SDK, encryption library, account service, or network package is required. The file dependency transports bytes only; project code owns all validation and the unranked trust policy.",
    "docs: update Game Backup dependency details",
)

append(
    "CONTRIBUTING.md",
    "## File-based Game Backup changes",
    """## File-based Game Backup changes

Changes to file backup transport must preserve these additional rules:

- keep `GameBackupFilePort` as the testable platform boundary;
- keep `.nova2048` / `.json` extensions as chooser hints only, never trust signals;
- enforce a bounded byte length before UTF-8/JSON processing;
- route accepted text through `GameBackup.decode()` rather than duplicating a parser;
- route state replacement through `AppController.importGameBackup()` so file restores remain persistently unranked;
- preserve explicit user selection and avoid background directory scanning/path retention;
- update macOS sandbox entitlements deliberately if file-access requirements change;
- add widget/domain tests and run the native build matrix for plugin/configuration changes.

See [`docs/FILE_BACKUPS.md`](docs/FILE_BACKUPS.md).
""",
    "docs: add file backup contribution rules",
)

append(
    "docs/DEVELOPMENT.md",
    "## File backup development",
    """## File backup development

Phase 20 adds a platform-plugin boundary under `lib/shared/game_backup_file_port.dart`. Feature/UI code should depend on `GameBackupFilePort`; pure backup validation remains in `lib/domain/game_backup.dart` and trusted-state installation remains in `AppController`.

When changing this integration, run the normal formatter/analyzer/full test/Web gate and the configured native matrix. Plugin or entitlement changes especially require Android, Linux, Windows, macOS, and unsigned-iOS compilation plus real-platform picker checks before stable release.
""",
    "docs: document file backup development workflow",
)
append(
    "docs/USER_GUIDE.md",
    "## Save or open a backup file",
    """## Save or open a backup file

Game Backup now supports the same current-game envelope through clipboard or file transport.

- Choose **Save backup file** to open the platform/browser save flow with a suggested `.nova2048` filename.
- Choose **Import backup file** to select one `.nova2048` or `.json` file.
- A cancelled picker changes nothing.
- Oversized, non-UTF-8, malformed, unsupported, or invalid game-state content is rejected.
- A valid file shows the same **Restore unranked backup?** preview as clipboard import.
- Restoring always replaces only after explicit confirmation and the session remains unranked after restart.

The app does not automatically scan folders or upload backup files. See [`FILE_BACKUPS.md`](FILE_BACKUPS.md).
""",
    "docs: add file backup user guide",
)
append(
    "docs/FAQ.md",
    "## Can I save Game Backup as a file?",
    """## Can I save Game Backup as a file?

Yes. Phase 20 adds **Save backup file** and **Import backup file** in addition to clipboard copy/import. The recommended extension is `.nova2048`; `.json` can also be selected where the platform filter supports it. Both contain the same versioned Game Backup JSON.

A file is not trusted because of its name or extension. Imported files use the same strict validation, explicit confirmation, and persistent unranked policy as clipboard imports.
""",
    "docs: answer file backup FAQ",
)
append(
    "docs/TROUBLESHOOTING.md",
    "## Backup file will not save or open",
    """## Backup file will not save or open

If **Save backup file** or **Import backup file** does not complete:

1. confirm the platform file dialog/browser download was not cancelled;
2. try a local user-writable/user-readable location offered by the picker;
3. use a `.nova2048` or `.json` file;
4. confirm the file is valid UTF-8 text and below the 512 KiB pre-decode file limit;
5. remember that the embedded JSON still has the stricter 128 Ki-character Game Backup protocol limit;
6. on Web, check browser download/file-input permissions and download blocking;
7. on macOS, use the user-selected picker flow rather than trying to grant arbitrary folder access;
8. if the chooser itself fails, clipboard Game Backup remains a separate transport for the same validated envelope.

A rejected file should never replace the current game. Report reproducible platform/plugin failures with OS, target, action, and whether cancellation or validation feedback appeared.
""",
    "docs: add file backup troubleshooting",
)
append(
    "docs/TESTING.md",
    "## Phase 20 file backup coverage",
    """## Phase 20 file backup coverage

Phase 20 adds **6 focused automated tests** over the Phase 19 total of 183, producing **189 tests** in the first clean Phase 20 functional gate.

New/expanded coverage verifies file export round trip and extension, cancelled file export, valid file import through the existing unranked confirmation path, cancelled file selection, pre-confirmation oversized-file rejection, and Hindi file-backup catalog coverage. Existing clipboard backup, codec, imported-session ranking, persistence, and localization tests remain active.

First clean functional gate after the analyzer fix:

```text
Commit: 1cd1b4230f6200c9208709d0c76f12fd3a20fce2
CI run: 31874929593
CI job: 94989136815
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 91 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 189/189
Web release: PASS — build/web
Web WASM dry run: PASS
```

The final current-source Phase 20 CI/native matrix is recorded separately after all source/documentation synchronization is complete. Hosted tests cannot replace real platform Save/Open dialog and document-provider behavior.
""",
    "docs: record Phase 20 file backup tests",
)
append(
    "docs/PLATFORMS.md",
    "## Phase 20 file picker integration",
    """## Phase 20 file picker integration

Game Backup file transport is configured for Android, iOS, Web, Windows, macOS, and Linux through pinned `file_picker 11.0.2` behind `GameBackupFilePort`.

macOS Debug/Profile and Release entitlements enable `com.apple.security.files.user-selected.read-write`. This grants access to files chosen by the user, not arbitrary filesystem traversal.

Web uses the browser's download/file-input behavior; native targets use their platform picker/document-provider behavior. Hosted release builds verify compilation/integration only. Real Save/Open/cancel/round-trip checks remain required on representative targets before stable `1.0.0`.
""",
    "docs: document Phase 20 platform integration",
)
append(
    "docs/CI_CD.md",
    "## Phase 20 plugin qualification",
    """## Phase 20 plugin qualification

Because Phase 20 adds `file_picker` and macOS sandbox entitlements, its final acceptance requires both the normal CI gate and the configured native Platform Builds workflow on the completed runtime tree. The normal CI covers dependency resolution, formatting, analyzer, 189 tests, Web release, and Web WASM dry-run compatibility. Platform Builds provides Android/Linux/Windows/macOS/unsigned-iOS compilation evidence.

Neither workflow performs interactive system picker qualification. Save/Open/cancel/document-provider/browser-download behavior remains a manual release boundary.
""",
    "docs: document Phase 20 CI qualification",
)
append(
    "docs/RELEASE_CHECKLIST.md",
    "## Phase 20 Game Backup file checks",
    """## Phase 20 Game Backup file checks

Do not mark stable `1.0.0` ready until representative real environments verify:

- [ ] `.nova2048` Save/Save As success and cancellation;
- [ ] `.nova2048` export/import round trip into a fresh app session;
- [ ] `.json` selection where exposed by the platform picker;
- [ ] Web browser download and file-input behavior;
- [ ] Android/iOS document-provider behavior, including a user-selected cloud-backed document where practical;
- [ ] Windows/Linux native picker behavior;
- [ ] macOS sandboxed user-selected read/write behavior;
- [ ] oversized, non-UTF-8, malformed, unsupported-version, and invalid-state rejection without live-game mutation;
- [ ] large-but-valid backup responsiveness;
- [ ] persistent unranked status after file restore/restart and Undo after imported moves;
- [ ] Hindi, large text, keyboard/focus, and representative screen-reader behavior for file actions/errors/confirmation.

Hosted compilation is evidence of build compatibility, not completion of these interactive checks.
""",
    "docs: add Phase 20 release checks",
)

append(
    "docs/README.md",
    "## Phase 20 file backup documentation",
    """## Phase 20 file backup documentation

- [`FILE_BACKUPS.md`](FILE_BACKUPS.md) — `.nova2048` / `.json` Game Backup file transport, byte bounds, platform behavior, macOS sandbox scope, trust model, dependency boundary, tests, and manual qualification.
- [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) — shared clipboard/file backup envelope and persistent unranked restore policy.
""",
    "docs: index file backup documentation",
)

append(
    "CHANGELOG.md",
    "### Phase 20 — File-based Game Backup",
    """### Phase 20 — File-based Game Backup

- Added explicit user-selected Game Backup file export/import using the existing version-1 backup envelope and `.nova2048` / `.json` chooser filters.
- Added `GameBackupFilePort` and pinned `file_picker 11.0.2` so platform transport stays isolated from domain validation and ranked-state policy.
- Added a 512 KiB pre-decode file byte limit plus strict UTF-8 before the existing 128 Ki-character JSON protocol bound.
- Added macOS user-selected read/write sandbox entitlement for Debug/Profile and Release.
- File restores use the same explicit preview and persistent unranked `AppController.importGameBackup()` path as clipboard restores.
- Added five file-flow widget regressions plus one Hindi catalog regression, bringing the first clean Phase 20 gate to 189/189 tests.
- First clean gate: CI `31874929593` on `1cd1b4230f6200c9208709d0c76f12fd3a20fce2` passed formatting (91 files, 0 changes), analyzer, 189 tests, Web release, and WASM dry run.
""",
    "docs: add Phase 20 to changelog",
)

print("Phase 20 documentation updates complete")
