# Security Policy

2048 Nova is an offline-first Flutter puzzle game. Security work focuses on safe local-data parsing, external-link handling, portable-input validation, dependency hygiene, platform build configuration, and avoiding accidental secret/private-data exposure.

## Supported version

The repository is currently maintained on the **Version 1.5** line (`1.5.0+15` candidate metadata). Security fixes are applied to the active `main` development line. There is not yet a separately maintained long-term-support release branch.

## Reporting a vulnerability

Please report potential security issues privately to:

**supportramsandesh@gmail.com**

Do not publish sensitive exploit details in a public issue before the maintainer has had a reasonable opportunity to review them.

A useful private report includes:

- affected commit/version;
- platform and OS;
- component or file involved;
- reproducible steps;
- expected security boundary;
- actual behavior;
- impact assessment;
- suggested remediation if known.

Do **not** include unrelated personal information, account credentials, passwords, access tokens, private keys, signing certificates, provisioning profiles, or production secrets.

## Public bugs versus security reports

Normal gameplay defects, UI problems, accessibility issues, or crashes without a meaningful confidentiality/integrity/security impact can use the public bug template.

Use the private security contact when a report involves areas such as:

- unsafe external URL/scheme execution;
- malicious Challenge Code or portable backup parsing with security impact;
- unintended local-data disclosure;
- dependency vulnerability with a practical project impact;
- credential/signing material exposure;
- code execution beyond intended application behavior;
- platform packaging behavior that weakens an expected security boundary.

## Current security boundaries

### Local persistence

Persisted JSON is not trusted blindly. Current-game, Undo, settings, statistics, achievements, and Daily history are parsed defensively. Malformed current-game state is removed together with associated Undo/ranking metadata so stale data cannot silently attach to another session.

### Challenge Codes

Challenge Code text is untrusted portable input. The decoder validates:

- maximum 1024-character input length before payload parsing;
- exact `NOVA1` prefix and three-segment shape;
- non-empty payload;
- exactly eight hexadecimal checksum characters;
- FNV-1a checksum match before payload decode;
- Base64URL/UTF-8 validity;
- JSON envelope type;
- exact `2048-nova-challenge` format identifier;
- supported schema version;
- required configuration object;
- strict `GameConfig.fromJson()` bounds/types;
- required deterministic seed;
- supported non-Daily mode allowlist.

A valid code carries only a fresh-game configuration and seed. It cannot import a board position, score, lifetime statistics, achievements, streaks, settings, Daily history, or Undo snapshots.

The checksum is **not cryptographic authentication**. It does not prove who created a code, prevent a technically capable person from constructing another valid code, encrypt the payload, or provide anti-cheat guarantees. It exists to catch accidental corruption/editing. This is acceptable for the current local-only feature because codes cannot assert progress or trusted records.

Starting a code still uses the normal recoverable-game replacement confirmation and then the normal new-game path. Daily mode is rejected so arbitrary code text cannot enter the date-indexed Daily-history contract.

### Portable Game Backup

Clipboard text and user-selected backup files are untrusted input. File import first bounds the reported and actual byte length and requires strict UTF-8. The shared backup decoder then checks:

- maximum input length before JSON parsing;
- backup format;
- backup version;
- timestamp validity;
- embedded game object;
- strict `GameState` structure and values.

Import requires explicit confirmation and always creates an **unranked** current-game session. External backup content cannot import lifetime statistics, achievements, settings, Daily history, or old Undo data and cannot choose its own ranked status.

Portable backup JSON is not encrypted, signed, or authenticated. A `.nova2048` extension, filename, local path, or document-provider location is not proof of authenticity. Users should treat copied or saved backup data as editable portable game state and share it only intentionally.

### Clipboard boundary

Challenge Codes and Game Backup use the shared `TextClipboard` abstraction. Production uses Flutter's system clipboard API; tests can inject an in-memory implementation.

Clipboard content is controlled by the operating system/browser environment. The app reads or writes portable text only after explicit user actions, but it cannot guarantee how the platform itself stores, synchronizes, or exposes clipboard history. Users should not put unrelated secrets into the application's portable-text input fields.

### External links

External navigation goes through a shared allowlist helper. Supported destinations are secure `https` URLs with a host and non-empty `mailto` links. Unsupported/insecure schemes such as arbitrary JavaScript/file URLs are rejected.

If platform launching fails, the app provides a copy fallback instead of trying unsafe alternatives.

### Network exposure

The default game has no account backend, analytics SDK, advertising tracker, cloud synchronization, or external AI service. Normal gameplay, Challenge Codes, Daily Challenge generation, Hint, Auto Play Demo, Replay, statistics, achievements, and local save/resume do not require a project server.

### Auto Play and Replay

Auto Play Demo is an isolated in-memory heuristic sandbox. Replay is read-only and uses defensive snapshot copies. Neither feature should become a path for mutating trusted player records outside the controller's normal policy.

## Secrets and signing material

Never commit:

- GitHub personal access tokens;
- API keys;
- passwords;
- Android keystores or keystore passwords;
- Apple certificates/private keys;
- provisioning profiles containing sensitive identity material;
- cloud credentials;
- private user data.

GitHub Actions repository-writing workflows use the normal GitHub-provided workflow token and commit as `Sanskar <sanskarin@outlook.in>`. The repository does not store that token in source.

The automated iOS release build is intentionally `--no-codesign`; real distribution signing belongs outside public source control.

## Dependencies

Runtime dependencies are intentionally small. Challenge Code encoding uses project/Dart primitives, while presentation and platform integrations remain narrowly scoped. Dependabot monitors Pub, Android Gradle, and GitHub Actions dependencies, and the pull-request dependency-review workflow rejects newly introduced high-severity vulnerable dependency changes. Dependency changes still require compatibility, license, privacy, analyzer, test, and build review.

If a dependency advisory affects this project, include the exact package/version and practical reachable impact in the report when possible.

## Disclosure and remediation expectations

After receiving a credible report, the maintainer should reproduce/triage it, determine affected versions, prepare a fix and regression test, update security/release documentation where necessary, and disclose publicly only when doing so no longer creates unnecessary risk.

No fixed response-time guarantee is promised by this open-source project, but responsible private reporting is preferred so a fix can be developed before detailed exploitation instructions are made public.

## Security-related testing

Relevant automated coverage includes malformed persisted-state recovery, strict configuration/state parsing, external URI allowlisting, stale Undo filtering, Challenge Code size/prefix/checksum/payload/config/mode validation, deterministic Challenge Code opening behavior, replacement cancellation, backup envelope validation, oversized-backup rejection, imported-session ranking isolation, and scoped project-data reset.

Automated tests do not replace real platform clipboard/security behavior, dependency advisory monitoring, assistive-technology review, or secure store-signing practices.

## Localization security boundary

Localization is static application data plus a validated local preference. No remote translation endpoint, locale-specific executable code, or downloaded language pack is used. Unknown persisted language values fall back to System default and cannot select arbitrary assets, URLs, or code paths.


## Per-mode record integrity

Per-mode records are convenience statistics, not cryptographic achievements. They are accepted only from the application's trusted local-session path; imported Game Backup progress is persistently marked unranked and cannot update them. Stored record fields are parsed defensively and bounded before use, and unknown future mode keys are ignored.

This boundary prevents the supported portable/editable backup format from directly inflating local mode records. It is not an anti-cheat or tamper-proof system: users with direct control of application storage can modify local preferences. Any future competitive/online ranking design would require a separate authenticated threat model rather than reusing these local records as proof.

## Full Replay Archive input boundary

Portable Full Replay Archive JSON is untrusted user-editable input. The decoder enforces a maximum encoded length, exact format and version, export timestamp, strict opening `GameState`, complete and non-overflowed capture flags, a maximum of 4,096 events, event type, direction and time validation, nondecreasing elapsed time, and deterministic action reconstruction. Invalid moves, impossible Undo, invalid continue-after-win, and redundant or invalid status-refresh actions fail closed.

Replay import is spectator-only and does not call the current-game import path. A structurally valid replay cannot assert trusted lifetime statistics, achievements, streaks, Daily history, or per-mode records. The format is not encrypted, signed, or authenticated; deterministic consistency does not establish player identity or anti-cheat authenticity.

Full Replay Archive uses the same explicit `TextClipboard` boundary as Challenge Codes and Game Backup. Copy and open actions read or write clipboard text only after user action. The platform may independently retain or synchronize clipboard history, so replay text should be treated as shareable gameplay data rather than a secret-storage mechanism.

## File picker boundary

Phase 20 pins `file_picker 11.0.2` for explicit Game Backup file selection/save transport. The plugin does not decide whether a backup is valid or ranked. The project applies size limits and UTF-8 decoding at `GameBackupFilePort`, domain validation at `GameBackup.decode()`, confirmation in the UI, and the permanent unranked policy in `AppController.importGameBackup()`.

macOS grants only `com.apple.security.files.user-selected.read-write` for files selected by the user. 2048 Nova does not intentionally enumerate arbitrary directories, retain recent-file paths, or add a cloud-storage/network SDK for backup transfer.

## Challenge Code QR trust boundary

A displayed Challenge Code QR is only another representation of the existing plain `NOVA1...` text. It does not provide authentication, identity, signing, encryption, anti-cheat protection, or proof that the sender played a particular game. The existing checksum remains accidental-corruption detection only.

2048 Nova renders the QR locally and does not add camera permission or an in-app scanner. Text obtained by any external scanner must still pass the same strict Challenge Code decoder before a challenge can start. Security reports should treat QR parsing/rendering, decoder validation, and replacement protection as separate boundaries rather than assuming the image itself establishes trust.
