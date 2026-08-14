# Security Policy

2048 Nova is an offline-first Flutter puzzle game. Security work focuses on safe local-data parsing, external-link handling, portable-backup validation, dependency hygiene, platform build configuration, and avoiding accidental secret/private-data exposure.

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
- malicious portable backup parsing with security impact;
- unintended local-data disclosure;
- dependency vulnerability with a practical project impact;
- credential/signing material exposure;
- code execution beyond intended application behavior;
- platform packaging behavior that weakens an expected security boundary.

## Current security boundaries

### Local persistence

Persisted JSON is not trusted blindly. Current-game, Undo, settings, statistics, achievements, and Daily history are parsed defensively. Malformed current-game state is removed together with associated Undo/ranking metadata so stale data cannot silently attach to another session.

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

### External links

External navigation goes through a shared allowlist helper. Supported destinations are secure `https` URLs with a host and non-empty `mailto` links. Unsupported/insecure schemes such as arbitrary JavaScript/file URLs are rejected.

If platform launching fails, the app provides a copy fallback instead of trying unsafe alternatives.

### Network exposure

The default game has no account backend, analytics SDK, advertising tracker, cloud synchronization, or external AI service. Normal gameplay, Daily Challenge generation, Hint, Auto Play Demo, Replay, statistics, achievements, and local save/resume do not require a project server.

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

Runtime dependencies are intentionally small. Dependabot is configured for ongoing update discovery, while dependency changes still require compatibility, license, privacy, and build review.

If a dependency advisory affects this project, include the exact package/version and practical reachable impact in the report when possible.

## Disclosure and remediation expectations

After receiving a credible report, the maintainer should reproduce/triage it, determine affected versions, prepare a fix and regression test, update security/release documentation where necessary, and disclose publicly only when doing so no longer creates unnecessary risk.

No fixed response-time guarantee is promised by this open-source project, but responsible private reporting is preferred so a fix can be developed before detailed exploitation instructions are made public.

## Security-related testing

Relevant automated coverage includes malformed persisted-state recovery, strict configuration/state parsing, external URI allowlisting, stale Undo filtering, backup envelope validation, oversized-backup rejection, imported-session ranking isolation, and scoped project-data reset.

Automated tests do not replace platform security review, dependency advisory monitoring, or secure store-signing practices.
