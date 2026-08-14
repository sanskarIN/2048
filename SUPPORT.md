# Support

This file explains where to ask for help with 2048 Nova and what information makes a report useful.

## Project help

- Repository: https://github.com/sanskarIN/2048
- Public issues: https://github.com/sanskarIN/2048/issues
- Bug report template: https://github.com/sanskarIN/2048/issues/new?template=bug_report.yml
- Feature requests: use the repository feature-request template.
- Documentation improvements: use the documentation issue template.
- Support email: **supportramsandesh@gmail.com**

Before filing a setup/build issue, check [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md), [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md), and the current [`docs/VERIFICATION.md`](docs/VERIFICATION.md).

## What to include in a bug report

Include enough detail to reproduce the issue:

- 2048 Nova version/commit if known;
- device/platform and OS version;
- Flutter/Dart version for development/build problems;
- game mode and board size;
- whether the game was a normal local game or an imported unranked backup;
- exact steps to reproduce;
- expected behavior;
- actual behavior;
- screenshots or logs when useful;
- whether the issue persists after starting a fresh game.

For save/Undo/Daily problems, do not publicly post private clipboard data or unrelated device information. If a portable backup reproduces a bug, inspect it before sharing because backup text contains the current game state in plain JSON.

## Security-sensitive reports

Do not open a public issue containing sensitive exploit details. Follow [`SECURITY.md`](SECURITY.md) and contact the support email privately.

Never send passwords, access tokens, API keys, payment credentials, signing keys, provisioning secrets, private keys, or other credentials in a support request.

## Business/contact

- Business: **sanskarin@outlook.in**
- Business: **sanskarin.business@gmail.com**
- GitHub profile: https://www.github.com/sanskarIN
- LinkedIn: https://www.linkedin.com/in/sanskarIN

## Buy Me a Coffee

Optional project support is available at:

https://buymeacoffee.com/sanskarIN

Financial support is never required to play, build, fork, or contribute to the MIT-licensed project.

## Scope of support

The repository documentation and issue tracker can help with reproducible project behavior and supported build workflows. They cannot guarantee support for every custom Flutter fork, unofficial modified dependency set, third-party store packaging system, rooted/jailbroken device configuration, or unsupported platform toolchain.

For real iOS distribution, Apple signing/provisioning must be configured outside this public repository. For Android store distribution, use normal private release-signing practices and do not commit the signing material.
