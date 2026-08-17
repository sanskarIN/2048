# Support

This file explains where to ask for help with 2048 Nova and what information makes a report useful.

## Project help

- Repository: https://github.com/sanskarIN/2048
- Public issues: https://github.com/sanskarIN/2048/issues
- Bug report template: https://github.com/sanskarIN/2048/issues/new?template=bug_report.yml
- Feature requests: use the repository feature-request template.
- Documentation improvements: use the documentation issue template.
- Support email: **supportramsandesh@gmail.com**
- Gumroad storefront: **https://ramsandesh.gumroad.com**

Before filing a setup/build issue, check [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md), [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md), and the current [`docs/VERIFICATION.md`](docs/VERIFICATION.md).

## What to include in a bug report

Include enough detail to reproduce the issue:

- 2048 Nova version/commit if known;
- device/platform and OS version;
- Flutter/Dart version for development/build problems;
- game mode and board size;
- whether the game was started normally, from a Challenge Code, or from an imported unranked backup;
- exact steps to reproduce;
- expected behavior;
- actual behavior;
- screenshots or logs when useful;
- whether the issue persists after starting a fresh game.

For Challenge Code problems, say which stage fails:

- Generate;
- Copy;
- Paste/manual entry;
- Validate;
- decoded preview;
- replacement confirmation;
- deterministic opening comparison;
- later same-move-sequence comparison.

If safe to do so, mention the mode and seed shown by the decoded preview. A complete Challenge Code contains only game configuration/seed, but you should still avoid posting unrelated clipboard content accidentally copied from another app.

For save/Undo/Daily problems, do not publicly post private clipboard data or unrelated device information. If a portable **Game Backup** reproduces a bug, inspect it before sharing because backup text contains the current game state in plain JSON.

Challenge Codes and Game Backup are different formats. `NOVA1...` Challenge Code text should be opened through Home → Challenge Codes, while current-game backup JSON belongs in Home → Game Backup.

## Security-sensitive reports

Do not open a public issue containing sensitive exploit details. Follow [`SECURITY.md`](SECURITY.md) and contact the support email privately.

Never send passwords, access tokens, API keys, payment credentials, signing keys, provisioning secrets, private keys, or other credentials in a support request.

The Challenge Code checksum is not secret/authentication material. Security reports should focus on an actual violated boundary, such as unsafe parsing/execution or unintended data exposure, rather than merely the fact that a user can construct a different valid configuration code.

## Business/contact

- Business: **sanskarin@outlook.in**
- Business: **sanskarin.business@gmail.com**
- GitHub profile: https://www.github.com/sanskarIN
- LinkedIn: https://www.linkedin.com/in/sanskarIN
- Gumroad: **https://ramsandesh.gumroad.com**

## Gumroad storefront

<a href="https://ramsandesh.gumroad.com">
  <img src="assets/branding/ramsandesh_gumroad_badge.svg" alt="Ramsandesh on Gumroad" width="310" />
</a>

The highlighted Ramsandesh Gumroad storefront is available at:

**https://ramsandesh.gumroad.com**

The repository uses an original storefront badge rather than claiming that the project is officially endorsed by Gumroad.

## Buy Me a Coffee

Optional project support is available at:

https://buymeacoffee.com/sanskarIN

Financial support is never required to play, build, fork, or contribute to the MIT-licensed project.

## Scope of support

The repository documentation and issue tracker can help with reproducible project behavior and supported build workflows. They cannot guarantee support for every custom Flutter fork, unofficial modified dependency set, third-party store packaging system, rooted/jailbroken device configuration, or unsupported platform toolchain.

Real clipboard behavior can differ across browsers/operating systems, so a code/backup flow that passes automated widget tests may still need platform-specific diagnosis.

For real iOS distribution, Apple signing/provisioning must be configured outside this public repository. For Android store distribution, use normal private release-signing practices and do not commit the signing material.

## Language-related reports

For a localization issue, include the selected language (**System default**, **English**, or **हिन्दी**), device/platform, the exact screen/label, and the expected wording or layout behavior. For System default problems, also include the device language/region. Do not include unrelated private device data.
