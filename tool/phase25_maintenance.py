from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


def replace_required(path: str, old: str, new: str, count: int = 1) -> None:
    text = read(path)
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old!r}")
    write(path, text.replace(old, new, count))


# Align the declared toolchain with the maintained Version 1.5 dependency set.
pubspec = read("pubspec.yaml")
for old, new in [
    ('  sdk: ">=3.3.0 <4.0.0"', '  sdk: ">=3.9.0 <4.0.0"\n  flutter: ">=3.35.0"'),
    ("  cupertino_icons: 1.0.8", "  cupertino_icons: 1.0.9"),
    ("  shared_preferences: ^2.5.3", "  shared_preferences: ^2.5.5"),
    ("  flutter_lints: ^5.0.0", "  flutter_lints: ^6.0.0"),
]:
    if old not in pubspec:
        raise SystemExit(f"Expected pubspec text not found: {old!r}")
    pubspec = pubspec.replace(old, new, 1)
write("pubspec.yaml", pubspec)

# Keep repository-integrity checks synchronized with the maintained dependency policy.
integrity_path = "test/repository_integrity_test.dart"
integrity = read(integrity_path)
integrity = integrity.replace("cupertino_icons: 1.0.8", "cupertino_icons: 1.0.9", 1)
integrity = integrity.replace('version: "1.0.8"', 'version: "1.0.9"', 1)
marker = "    test('runtime version matches pubspec marketing version', () {"
new_tests = r'''    test('declared SDK floor matches maintained dependencies', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('sdk: ">=3.9.0 <4.0.0"'));
      expect(pubspec, contains('flutter: ">=3.35.0"'));
      expect(pubspec, contains('shared_preferences: ^2.5.5'));
      expect(pubspec, contains('flutter_lints: ^6.0.0'));
    });

    test('supply-chain automation covers maintained dependency ecosystems', () {
      final dependabot = File('.github/dependabot.yml').readAsStringSync();
      final dependencyReview = File(
        '.github/workflows/dependency-review.yml',
      ).readAsStringSync();

      for (final ecosystem in <String>['pub', 'gradle', 'github-actions']) {
        expect(dependabot, contains('package-ecosystem: $ecosystem'));
      }
      expect(dependabot, isNot(contains('- dependencies')));
      expect(dependencyReview, contains('actions/dependency-review-action@v4'));
      expect(dependencyReview, contains('fail-on-severity: high'));
    });

    test('CODEOWNERS covers release and platform policy', () {
      final owners = File('.github/CODEOWNERS').readAsStringSync();

      expect(owners, contains('* @sanskarIN'));
      expect(owners, contains('/.github/ @sanskarIN'));
      expect(owners, contains('/pubspec.yaml @sanskarIN'));
      expect(owners, contains('/docs/RELEASE* @sanskarIN'));
      expect(owners, contains('/android/ @sanskarIN'));
      expect(owners, contains('/ios/ @sanskarIN'));
    });

    test('security policy tracks the current Version 1.5 line', () {
      final policy = File('SECURITY.md').readAsStringSync();

      expect(policy, contains('Version 1.5'));
      expect(policy, contains('supportramsandesh@gmail.com'));
      expect(policy, contains('dependency-review'));
    });

'''
if marker not in integrity:
    raise SystemExit("Repository-integrity insertion point not found")
integrity = integrity.replace(marker, new_tests + marker, 1)
write(integrity_path, integrity)

# Refresh security policy version/dependency maintenance statements without rewriting historical boundaries.
security = read("SECURITY.md")
old = "The repository is currently on the `0.9.0+1` release-candidate line. Security fixes are applied to the active `main` development line. There is not yet a separately maintained long-term-support release branch."
new = "The repository is currently maintained on the **Version 1.5** line (`1.5.0+15` candidate metadata). Security fixes are applied to the active `main` development line. There is not yet a separately maintained long-term-support release branch."
if old not in security:
    raise SystemExit("SECURITY supported-version paragraph not found")
security = security.replace(old, new, 1)
old = "Runtime dependencies are intentionally small. Challenge Codes use only Dart/Flutter primitives and add no third-party runtime package. Dependabot is configured for ongoing update discovery, while dependency changes still require compatibility, license, privacy, and build review."
new = "Runtime dependencies are intentionally small. Challenge Code encoding uses project/Dart primitives, while presentation and platform integrations remain narrowly scoped. Dependabot monitors Pub, Android Gradle, and GitHub Actions dependencies, and the pull-request dependency-review workflow rejects newly introduced high-severity vulnerable dependency changes. Dependency changes still require compatibility, license, privacy, analyzer, test, and build review."
if old not in security:
    raise SystemExit("SECURITY dependency paragraph not found")
security = security.replace(old, new, 1)
write("SECURITY.md", security)

# Make README prerequisites explicit and include the icon-font dependency boundary.
readme = read("README.md")
old = "Runtime dependencies beyond Flutter are intentionally limited to:\n\n- `file_picker`"
new = "Runtime dependencies beyond Flutter are intentionally limited to:\n\n- `cupertino_icons` — explicit Cupertino icon-font asset required by referenced Cupertino icon data and guarded by the Web build.\n- `file_picker`"
if old not in readme:
    raise SystemExit("README dependency list insertion point not found")
readme = readme.replace(old, new, 1)
old = "Install a current stable Flutter SDK and the platform toolchain for the target you want to build. Confirm the environment with:"
new = "Install **Flutter 3.35 or newer with Dart 3.9 or newer** and the platform toolchain for the target you want to build. Permanent CI uses the current stable Flutter channel. Confirm the environment with:"
if old not in readme:
    raise SystemExit("README prerequisite paragraph not found")
readme = readme.replace(old, new, 1)
write("README.md", readme)

# Align development requirements with pubspec's real dependency floor.
development = read("docs/DEVELOPMENT.md")
old = "Install a stable Flutter SDK and the native toolchain required by the platform you intend to run. GitHub Actions currently verifies with the stable Flutter channel; current release evidence is recorded in [`VERIFICATION.md`](VERIFICATION.md)."
new = "Install Flutter **3.35 or newer** with Dart **3.9 or newer**, plus the native toolchain required by the platform you intend to run. These floors match `pubspec.yaml` and the maintained Version 1.5 dependency set. GitHub Actions verifies with the current stable Flutter channel; current release evidence is recorded in [`VERIFICATION.md`](VERIFICATION.md)."
if old not in development:
    raise SystemExit("DEVELOPMENT requirements paragraph not found")
development = development.replace(old, new, 1)
write("docs/DEVELOPMENT.md", development)

# Refresh dependency policy for the new maintained SDK floor and direct versions.
deps = read("docs/DEPENDENCIES.md")
deps = deps.replace("Pinned at **1.0.8**.", "Pinned at **1.0.9**.", 1)
old = "Version 1.0.8 is intentionally pinned for the current release-candidate SDK range (`>=3.3.0 <4.0.0`) rather than blindly adopting a newer release with a higher Dart SDK floor. It adds no networking, analytics, account, persistence, or platform permission behavior."
new = "Version 1.0.9 is pinned for the maintained Version 1.5 toolchain. The project now declares Dart `>=3.9.0 <4.0.0` and Flutter `>=3.35.0`, matching the package's supported floor instead of advertising an older toolchain that cannot resolve the maintained dependency set. It adds no networking, analytics, account, persistence, or platform permission behavior."
if old not in deps:
    raise SystemExit("DEPENDENCIES Cupertino SDK paragraph not found")
deps = deps.replace(old, new, 1)
old = "### shared_preferences\n\nUsed for small local project-owned values such as:"
new = "### shared_preferences\n\nDeclared at **^2.5.5** for Version 1.5 and used for small local project-owned values such as:"
if old not in deps:
    raise SystemExit("DEPENDENCIES shared_preferences heading not found")
deps = deps.replace(old, new, 1)
old = "### flutter_lints\n\nProvides baseline static-analysis rules, supplemented by project-specific analyzer rules in `analysis_options.yaml`."
new = "### flutter_lints\n\nDeclared at **^6.0.0**. It provides the current baseline Flutter static-analysis rules, supplemented by project-specific analyzer rules in `analysis_options.yaml`. The upgraded lint set is required to pass with zero analyzer issues before dependency changes are accepted."
if old not in deps:
    raise SystemExit("DEPENDENCIES flutter_lints paragraph not found")
deps = deps.replace(old, new, 1)
old = "A dedicated GitHub Actions workflow automatically resolves/commits lockfile changes when dependency metadata changes and can also be manually dispatched. Permanent CI independently fails when `flutter pub get` would change the committed lockfile, while Dependabot provides update discovery. Dependency updates still require analyzer/test/build verification."
new = "A dedicated GitHub Actions workflow automatically resolves/commits lockfile changes when dependency metadata changes and can also be manually dispatched. Permanent CI independently fails when `flutter pub get` would change the committed lockfile. Dependabot monitors Pub, Android Gradle, and GitHub Actions, while the pull-request dependency-review workflow rejects newly introduced high-severity vulnerable dependency changes. Dependency updates still require analyzer/test/build verification."
if old not in deps:
    raise SystemExit("DEPENDENCIES lockfile policy paragraph not found")
deps = deps.replace(old, new, 1)
write("docs/DEPENDENCIES.md", deps)

# Add a focused supply-chain document.
supply_chain = """# Supply-Chain Maintenance\n\n2048 Nova keeps dependency and automation maintenance fail-closed where practical while preserving a small runtime dependency surface.\n\n## Maintained toolchain floor\n\nVersion 1.5 declares:\n\n- Dart: `>=3.9.0 <4.0.0`\n- Flutter: `>=3.35.0`\n\nThese floors match the maintained direct dependency set instead of advertising SDK versions that cannot resolve it. Permanent CI still tests the current stable Flutter channel.\n\n## Direct dependency policy\n\nThe maintained direct package set is intentionally narrow:\n\n- `cupertino_icons 1.0.9` — explicit Cupertino icon-font asset;\n- `file_picker 11.0.2` — explicit user-selected Game Backup file transport;\n- `qr_flutter 4.1.0` — local Challenge Code QR rendering only;\n- `shared_preferences ^2.5.5` — local project-owned state/preferences;\n- `url_launcher ^6.3.2` — validated external browser/email handoff;\n- `flutter_lints ^6.0.0` — development-time analyzer baseline.\n\nFlutter SDK packages such as `flutter_localizations` remain SDK dependencies rather than third-party services.\n\n## Dependabot\n\n`.github/dependabot.yml` checks three ecosystems weekly:\n\n1. Pub packages at repository root;\n2. Android Gradle metadata under `/android`;\n3. GitHub Actions workflow dependencies.\n\nThe configuration intentionally does not require a repository label that may not exist. Update pull requests must still pass normal CI and relevant native-build verification before merge.\n\n## Pull-request dependency review\n\n`.github/workflows/dependency-review.yml` runs for pull requests that change Pub, Android, or GitHub Actions dependency surfaces. It uses GitHub's dependency-review action and fails when a dependency change introduces a known **high-or-higher severity** vulnerability.\n\nThis is an additional gate, not a replacement for maintainer review. License, privacy, platform support, binary-size, API compatibility, and reachable project impact must still be considered.\n\n## Lockfile and generated metadata\n\n`pubspec.lock` is committed because 2048 Nova is an application. CI runs `flutter pub get` and fails when the committed lockfile or Flutter-managed analysis metadata drifts. The dedicated dependency-lock workflow can resolve intentional manifest changes, but permanent CI remains the independent verification gate.\n\n## Code ownership\n\n`.github/CODEOWNERS` routes default repository ownership and sensitive release/dependency/platform paths to `@sanskarIN`. Branch-protection enforcement is a repository setting and is not implied merely by the presence of the CODEOWNERS file.\n\n## Acceptance checks for dependency changes\n\nBefore accepting a dependency update:\n\n1. confirm the package is needed and maintained;\n2. confirm its SDK/platform floors match `pubspec.yaml`;\n3. review release notes and breaking changes;\n4. review licenses and privacy/network behavior;\n5. regenerate and inspect the lockfile;\n6. run formatter and static analysis;\n7. run the complete Flutter test suite;\n8. run candidate/stable release-gate checks;\n9. run the deterministic solver smoke benchmark;\n10. build Web release without missing-font warnings;\n11. run relevant Android/Linux/Windows/macOS/iOS hosted builds for runtime/plugin changes;\n12. keep real-device/signing qualification separate from hosted build evidence.\n\n## Stable-release boundary\n\nSupply-chain automation cannot satisfy the 13 real-world release qualification checks. Physical-device behavior, assistive technology, external handlers, long sessions, native branding, and production signing/provisioning remain evidence-backed manual release boundaries in `release_qualification.json`.\n"""
write("docs/SUPPLY_CHAIN.md", supply_chain)

# Link the supply-chain policy from the documentation index.
docs_index = read("docs/README.md")
old = "| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Runtime/development dependency rationale and licensing notes. |"
new = old + "\n| [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md) | SDK floors, dependency update automation, dependency review, lockfile policy, code ownership, and acceptance checks. |"
if old not in docs_index:
    raise SystemExit("Documentation index dependency row not found")
docs_index = docs_index.replace(old, new, 1)
write("docs/README.md", docs_index)

# Record Phase 25 release-facing maintenance changes and clean stale current-state wording.
changelog = read("CHANGELOG.md")
added_marker = "### Added\n"
added = (
    "- Pull-request dependency review for Pub, Android Gradle, and GitHub Actions dependency surfaces, failing on newly introduced high-severity vulnerable dependency changes.\n"
    "- Repository CODEOWNERS coverage for default, release, dependency, automation, and platform-sensitive paths.\n"
    "- Dedicated supply-chain maintenance documentation covering SDK floors, Dependabot, dependency review, lockfile policy, code ownership, and dependency acceptance checks.\n"
)
if added_marker not in changelog:
    raise SystemExit("CHANGELOG Added marker not found")
changelog = changelog.replace(added_marker, added_marker + added, 1)
changed_marker = "### Changed\n"
changed = (
    "- Version 1.5 now declares Dart `>=3.9.0 <4.0.0` and Flutter `>=3.35.0`, matching the maintained dependency floor.\n"
    "- Updated direct maintenance pins to `cupertino_icons 1.0.9`, `shared_preferences ^2.5.5`, and `flutter_lints ^6.0.0`; current stable `file_picker`, `qr_flutter`, and `url_launcher` pins remain unchanged.\n"
    "- Dependabot now covers Pub, Android Gradle, and GitHub Actions without depending on a repository label that is not guaranteed to exist.\n"
)
if changed_marker not in changelog:
    raise SystemExit("CHANGELOG Changed marker not found")
changelog = changelog.replace(changed_marker, changed_marker + changed, 1)
changelog = changelog.replace(
    "Maintained CI now passes 208/208 tests, 98-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.",
    "Maintained CI now passes 215/215 tests, 98-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.",
    1,
)
changelog = changelog.replace(
    "Permanent CI now formats `tool/`, validates release-candidate metadata, proves the stable gate remains closed on the `0.9.x` line, smoke-runs both deterministic solver strategies, and then produces the Web release build.",
    "Permanent CI formats `tool/`, validates Version 1.5 candidate metadata, proves the stable gate remains fail-closed while real-world qualification is incomplete, smoke-runs both deterministic solver strategies, and then produces the Web release build.",
    1,
)
changelog = changelog.replace(
    "Stable `1.0.0` promotion criteria are machine-enforced instead of depending only on prose checklists; pending real-world checks remain explicit rather than being fabricated from hosted automation.",
    "Stable Version 1.5 promotion criteria are machine-enforced instead of depending only on prose checklists; pending real-world checks remain explicit rather than being fabricated from hosted automation.",
    1,
)
write("CHANGELOG.md", changelog)
