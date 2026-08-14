# Security Policy

2048 Nova is an offline-first Flutter puzzle game. Security work focuses on safe local-data parsing, external-link handling, portable-input validation, dependency hygiene, platform build configuration, and avoiding accidental secret/private-data exposure.

## Supported version

The repository is currently on the `0.9.0+1` release-candidate line. Security fixes are applied to the active `main` development line. There is not yet a separately maintained long-term-support release branch.

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

Clipboard backup text is untrusted input. The application checks:

- maximum input length before JSON parsing;
- backup format;
- backup version;
- timestamp validity;
- embedded game object;
- strict `GameState` structure and values.

Import requires explicit confirmation and always creates an **unranked** current-game session. External backup content cannot import lifetime statistics, achievements, settings, Daily history, or old Undo data and cannot choose its own ranked status.

Portable backup JSON is not encrypted, signed, or authenticated. Users should treat copied backup text as ordinary clipboard data and share it only intentionally.

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

Runtime dependencies are intentionally small. Challenge Codes use only Dart/Flutter primitives and add no third-party runtime package. Dependabot is configured for ongoing update discovery, while dependency changes still require compatibility, license, privacy, and build review.

If a dependency advisory affects this project, include the exact package/version and practical reachable impact in the report when possible.

## Disclosure and remediation expectations

After receiving a credible report, the maintainer should reproduce/triage it, determine affected versions, prepare a fix and regression test, update security/release documentation where necessary, and disclose publicly only when doing so no longer creates unnecessary risk.

No fixed response-time guarantee is promised by this open-source project, but responsible private reporting is preferred so a fix can be developed before detailed exploitation instructions are made public.

## Security-related testing

Relevant automated coverage includes malformed persisted-state recovery, strict configuration/state parsing, external URI allowlisting, stale Undo filtering, Challenge Code size/prefix/checksum/payload/config/mode validation, deterministic Challenge Code opening behavior, replacement cancellation, backup envelope validation, oversized-backup rejection, imported-session ranking isolation, and scoped project-data reset.

Automated tests do not replace real platform clipboard/security behavior, dependency advisory monitoring, assistive-technology review, or secure store-signing practices.
