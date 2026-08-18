# Phase 30 Verification — Guarded Release Qualification Recorder

## Scope

Phase 30 reduces the risk of malformed or misleading edits to `docs/release_qualification.json` by adding a dedicated maintenance CLI while preserving the existing fail-closed stable-release policy.

This phase does **not** claim that any physical-device, assistive-technology, long-session, external-handler, signing/provisioning, branding-presentation, or store-metadata qualification has been completed.

## Source changes

Implemented:

- `tool/record_release_qualification.dart`
- `test/release_qualification_recorder_cli_test.dart`
- `docs/QUALIFICATION_RECORDER.md`

Relevant implementation commits:

- `10611015996014611018936b95195dbc5f28eeb0` — `feat: add guarded release qualification recorder`
- `59a61beb7de19be739b1ad8af6180c2c66bf91f7` — `test: cover release qualification recorder`
- `b5a11ad28b005001ab5008bdd949caffe24f5772` — `style: format Dart sources tests and tools`
- `1dd8fbaeed17fbe522cd9c4e2bfe259596c82426` — `docs: add release qualification recorder guide`

## Recorder contract

The recorder supports:

```bash
dart run tool/record_release_qualification.dart --list
```

and guarded mutations such as:

```bash
dart run tool/record_release_qualification.dart \
  --id=<required-check-id> \
  --status=passed \
  --evidence="<genuine real-world evidence>"
```

It also supports `blocked`, resetting back to `pending`, explicit ISO-8601 timestamps, `--dry-run`, and an alternate `--root=<path>` for regression fixtures.

## Safety and integrity boundaries

The recorder is intentionally unable to determine whether a device test really happened. It therefore does not infer qualification from CI, hosted builds, widget tests, generated artifacts, or fixture data.

For `passed` and `blocked`, the maintainer must explicitly provide evidence. Explicit timestamps must include `Z` or a numeric timezone offset; stored values are normalized to UTC. Returning an item to `pending` clears its evidence and timestamp so stale evidence is not retained accidentally.

The tool validates the manifest's schema shape, supported status set, exact required-ID set, duplicate IDs, missing IDs, unknown IDs, evidence requirements, and command-line option combinations before writing.

## Process-level regression coverage

`test/release_qualification_recorder_cli_test.dart` adds focused process-level coverage for:

1. `--list` read-only behavior.
2. Passed-result evidence recording.
3. Numeric-offset timestamp normalization to UTC.
4. Missing-evidence rejection.
5. Timezone-less timestamp rejection.
6. Unknown qualification-ID rejection.
7. Resetting an existing passed record back to pending.
8. `--dry-run` non-mutation behavior.

The existing `test/release_readiness_cli_test.dart` remains independent and continues to validate the final release gate itself.

## Formatting evidence

The repository's permanent `Format Dart` workflow reacted to the new `tool/` and `test/` files and produced:

- `b5a11ad28b005001ab5008bdd949caffe24f5772` — `style: format Dart sources tests and tools`

This confirms the newly added recorder sources were normalized by the repository-managed formatter workflow.

## Final repository hardening extension

The final audit of `main` found one real source/test consistency defect: `test/current_release_state_test.dart` still asserted that the continuity header was Phase 29 after `what_changed.md` had correctly advanced to Phase 30. That stale assertion would have caused the next complete test run to fail even though the continuity document was correct. It was repaired in:

- `23a319e9b29562f78cac429ff441037893acf201` — `test: align current release state with phase 30`

The release-state regression suite was then expanded to guard the Phase 30 recorder, documentation indexing, absence of temporary maintenance files, and permanent repository-audit CI wiring.

### Permanent repository integrity audit

Added `tool/repository_audit.dart` and `docs/REPOSITORY_AUDIT.md`. Permanent CI now executes:

```bash
dart run tool/repository_audit.dart --json
```

The audit fails closed for:

- missing or empty required repository/open-source/release/workflow files;
- package-version, in-app `ProjectInfo.version`, canonical repository metadata, and qualification-candidate drift;
- loss of `.gitignore` or the safe `android/key.properties.example` distribution-signing template;
- an incorrect count of the 13 manual qualification records;
- loss of the Phase 30 continuity and explicit `0/13` real-world boundary;
- known temporary Phase 30/31 maintenance files left in the finished repository;
- broken repository-local Markdown file/directory links.

It deliberately does not crawl external websites and does not convert hosted automation into real-device evidence.

Added `test/repository_audit_cli_test.dart` with isolated process-level fixtures covering a clean audit, broken local link rejection, runtime/package version drift, canonical repository metadata drift, qualification-candidate drift, temporary workflow rejection, and unclosed Markdown-fence warnings.

Relevant final-hardening commits include:

- `83454464ecd02892442db25ce0da2ebc7deb50f4` — `feat: add repository integrity audit CLI`
- `580529ffe223a55242f1512beceb7e10fa3f2411` — `fix: use static filesystem type check in audit`
- `97214893127c2176390a4d8182835106d6324db6` — `ci: enforce repository integrity audit`
- `d62d8eb3d0995a02577fdc7186153c0d95fd8b41` — `test: guard permanent repository audit wiring`
- `53f0e0533607b3c53e778ef5fd3f3458252ca3a1` — `docs: add repository integrity audit guide`
- `019feb79456d06287563ad1de3e176149eec3639c` — `test: cover repository integrity audit CLI`
- `09325af9e4095e9b5be9b6dcd6474f0440dbc73f` — `style: format Dart sources tests and tools`
- `5390bb9677e5f009826ce76d7ca73ed37e57d00b` — `chore: guard temporary finalizer cleanup`
- `aeaab4b7e8aeae98556bd7364de68134ab9df6d6` — `docs: index repository integrity audit`
- `d551bc16045b550bbc597a84896d4b81ff67d289` — `chore: require Android signing safety files in audit`
- `e5575beac85e8c82d0d22817aadd33a322c54349` — `test: cover Android signing safety files in audit fixture`
- `5c1d3e2f11a53b045eba63816993a3df140e802b` — `docs: include Android signing safety in repository audit`

The formatter commit above is objective evidence that the initial audit/test Dart files reached the repository-managed formatter. A newer complete CI result for the final source is **not** claimed here until the maintained verification PR completes and is inspected.

### Open-source maintenance hygiene

The final source-controlled pass also added:

- `.editorconfig` for consistent text handling across editors;
- `.gitattributes` for text/binary classification;
- `.github/FUNDING.yml` for the project's existing Buy Me a Coffee and Gumroad destinations;
- `.github/ISSUE_TEMPLATE/config.yml` to disable unstructured blank issues and route support/security questions to the maintained policies;
- `tool/README.md` as the maintainer entry point for repository auditing, release readiness, qualification evidence recording, and deterministic solver benchmarking.

The repository audit now requires the tooling index and scans local Markdown links under `tool/` together with the top-level, `docs/`, and `.github/` documentation surfaces.

No runtime dependency, analytics SDK, advertising SDK, account system, cloud service, camera permission, credential, signing key, or gameplay trust boundary was introduced by these maintenance additions.

### Final release metadata polish

The final metadata pass added canonical package project destinations to `pubspec.yaml`:

- `homepage: https://github.com/sanskarIN/2048`
- `repository: https://github.com/sanskarIN/2048`
- `issue_tracker: https://github.com/sanskarIN/2048/issues`

The repository audit and process fixtures now fail if these canonical destinations drift. The project-level integrity suite also guards the community/funding metadata and the canonical package destinations.

Windows and macOS visible copyright metadata previously used the phrase `All rights reserved.` while the source repository is MIT licensed. The phrase did not override the actual `LICENSE`, but it was misleading release-facing wording for an open-source project. It was replaced with `Licensed under the MIT License.` and regression coverage now guards both desktop metadata files against restoring the contradictory wording.

Relevant commits:

- `3fac70fea6a88b0d670d3a6ce57a0389694c8f6a` — `docs: add maintainer tooling index`
- `4e0e19e4259e3be1234ed3f7045c8371c06b099e` — `chore: audit maintainer tooling documentation`
- `05a503942d6b31e24e88129ff7ace318efae3529` — `test: include maintainer tooling index in audit fixture`
- `1c23646fe463e247999164b24895be1e79b4f05d` — `docs: align repository audit scope with tooling index`
- `f46dd3f493b44e1015391b1c5916859ab45e9e3f` — `chore: add canonical project metadata to pubspec`
- `0546d9c9e94fff59c39022f2ae4d63fb7f6448b5` — `chore: guard canonical pubspec project metadata`
- `6fab51132881be0f23c9248928409314be2db20c` — `test: guard canonical pubspec repository metadata`
- `b8124972be6e46a1abf10d9551412adccf1e962f` — `chore: align Windows copyright metadata with MIT license`
- `fdb76952d371478b43c9892949bdb29618495c2b` — `chore: align macOS copyright metadata with MIT license`
- `9f5a79dbb3a19d54a8cf3f2e5e792f6ff0eb723e` — `test: guard final open source release metadata`

The dependency set was not changed by this metadata pass; `pubspec.lock` remains the committed dependency lock source.

### Android distribution-signing support

The final build audit found that `android/app/build.gradle.kts` always selected the debug signing configuration for the `release` build type. This was intentional for hosted qualification, but it forced a maintainer to edit tracked Gradle source before creating a real production-signed APK/AAB.

The build now supports both paths without committing secrets:

- if ignored `android/key.properties` exists, Gradle loads the private alias/passwords/keystore and uses a real `release` signing configuration;
- if the file is absent, public CI deliberately falls back to debug signing for release-mode qualification builds;
- `storeFile` is resolved relative to `android/`;
- `android/key.properties.example` provides a safe committed template;
- `.gitignore` continues to exclude `android/key.properties`, `*.jks`, and `*.keystore`.

Added `test/android_signing_test.dart` to guard the ignored secret path, template fields, conditional release signing, Android-root-relative store path, qualification fallback, and absence of a tracked real keystore/key properties file.

Updated the master executable handbook, dedicated Android build guide, signing/distribution guide, and repository-audit documentation to describe the same behavior.

Relevant commits:

- `27913f41a5296773f9772050a5a21f5e3fed4764` — `build: support optional Android distribution signing`
- `e2c7fab8e14a3319097fb60f8d794116b217ce0b` — `fix: resolve Android signing store from project root`
- `166be61864236e36794472a28af617aa141a93b7` — `docs: add Android signing properties template`
- `427f31365d81872980aba8db5271c25285bb56a5` — `test: guard Android distribution signing contract`
- `f4f59731af56b6a3fade6c00adbdf972cc15ead6` — `docs: document optional Android distribution signing`
- `fc8f27f40beab976fb68c0f1e11d89b54a066abc` — `docs: align signing guide with Android release wiring`
- `b4fd78d868ad0697c2146371e397f5109367522b` — `docs: align master build handbook with signing support`

This wiring is not itself evidence that a private production key is valid or that a signed Play release has been qualified. Those remain genuine external/manual release tasks.

### Deliberate non-changes

The Android application namespace/application ID and Kotlin package remain `com.sanskarin.nova_2048`. They are internally consistent with each other and with manifest activity resolution. Renaming that identifier during final hardening would risk changing Android application identity/update behavior without fixing a demonstrated runtime defect, so it was deliberately left unchanged.

AGP 9.3.x remains deferred under GitHub issue #10 on the documented JDK 17 release-lint incompatibility. Repository protection remains tracked by issue #12 because branch/ruleset enforcement is a GitHub repository setting rather than a source file that can be truthfully simulated with YAML or CODEOWNERS.

## Manual qualification state

Phase 30 does not modify `docs/release_qualification.json` and does not create synthetic qualification evidence. The stable-release boundary therefore remains dependent on genuine completion of all required manual checks.

## Required follow-up before stable release

Continue using the real-target procedures already defined in the release, accessibility, backup, replay, Challenge Code, executable-build, and platform documentation. After each real check is genuinely performed, use the recorder to enter concise verifiable evidence, then validate with:

```bash
dart run tool/release_readiness.dart --json
```

Only after the complete real-world qualification set and stable metadata are ready should the strict gate be expected to pass:

```bash
dart run tool/release_readiness.dart --stable
```
