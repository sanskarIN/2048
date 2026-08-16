from pathlib import Path
import json


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


def replace_required(path: str, old: str, new: str, count: int = -1) -> None:
    text = read(path)
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old!r}")
    write(path, text.replace(old, new, count))


replace_required("pubspec.yaml", "version: 0.9.0+1", "version: 1.5.0+15", 1)
replace_required(
    "lib/core/constants/project_info.dart",
    "static const version = '0.9.0';",
    "static const version = '1.5.0';",
    1,
)

manifest_path = Path("docs/release_qualification.json")
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["candidate"] = "1.5.0+15"
manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

gate_path = "tool/release_readiness.dart"
gate = read(gate_path)
for old, new in {
    "Remaining release qualification before `1.0.0`": "Remaining release qualification before `1.5.0`",
    "explicit pre-1.0 release qualification boundary": "explicit pre-1.5 release qualification boundary",
    "r'^(?:0\\.9\\.\\d+|1\\.0\\.0)(?:\\+\\d+)?$'": "r'^1\\.5\\.\\d+(?:\\+\\d+)?$'",
    "pubspec version must remain in the 0.9.x release-candidate line or be 1.0.0 while using this gate; found $version.": "pubspec version must remain in the 1.5.x current release line while using this gate; found $version.",
    "r'^1\\.0\\.0(?:\\+\\d+)?$'": "r'^1\\.5\\.0(?:\\+\\d+)?$'",
    "## [1.0.0]": "## [1.5.0]",
    "Stable mode requires pubspec.yaml version 1.0.0 (optionally with a build number).": "Stable mode requires pubspec.yaml version 1.5.0 (optionally with a build number).",
    "Stable mode requires a CHANGELOG.md [1.0.0] release section.": "Stable mode requires a CHANGELOG.md [1.5.0] release section.",
}.items():
    if old not in gate:
        raise SystemExit(f"Expected release-gate text not found: {old!r}")
    gate = gate.replace(old, new)
write(gate_path, gate)

test_path = "test/release_readiness_cli_test.dart"
test_text = read(test_path)
for old, new in [
    ("String version = '0.9.0+1'", "String version = '1.5.0+15'"),
    ("'\\n## [1.0.0]\\n'", "'\\n## [1.5.0]\\n'"),
    ("Remaining release qualification before `1.0.0`", "Remaining release qualification before `1.5.0`"),
    ("expect(result.json['version'], '0.9.0+1');", "expect(result.json['version'], '1.5.0+15');"),
    ("version: '1.0.0+1'", "version: '1.5.0+15'"),
    ("fixture(version: '1.0.0', stableMetadata: true)", "fixture(version: '1.5.0', stableMetadata: true)"),
    ("fixture(candidate: '0.9.9+1')", "fixture(candidate: '1.5.99+99')"),
]:
    if old not in test_text:
        raise SystemExit(f"Expected test fixture text not found: {old!r}")
    test_text = test_text.replace(old, new)

insert_marker = "  test('candidate mismatch is rejected', () async {"
regression = """  test('legacy 0.9 candidate is rejected after the 1.5 migration', () async {
    final root = await fixture(version: '0.9.99+99');

    final result = await runGate(root);

    expect(result.process.exitCode, 1);
    expect(result.json['candidateGatePassed'], isFalse);
    expect(
      (result.json['failures'] as List<dynamic>).join('\\n'),
      contains('1.5.x current release line'),
    );
  });

"""
if insert_marker not in test_text:
    raise SystemExit("Could not locate release-gate regression insertion point")
test_text = test_text.replace(insert_marker, regression + insert_marker, 1)
write(test_path, test_text)

integrity_path = "test/repository_integrity_test.dart"
integrity = read(integrity_path)
marker = "    test('macOS generated registrant includes file picker', () {"
new_tests = """    test('runtime version matches pubspec marketing version', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final projectInfo = File(
        'lib/core/constants/project_info.dart',
      ).readAsStringSync();
      final match = RegExp(
        r'^version:\\s*([^+\\s]+)(?:\\+\\d+)?\\s*$',
        multiLine: true,
      ).firstMatch(pubspec);

      expect(match, isNotNull);
      final marketingVersion = match!.group(1)!;
      expect(
        projectInfo,
        contains("static const version = '$marketingVersion';"),
      );
    });

    test('CI stable boundary is qualification-driven, not version-prefix driven', () {
      final workflow = File('.github/workflows/ci.yml').readAsStringSync();

      expect(workflow, isNot(contains('version == 0.9.*')));
      expect(workflow, contains('pending|blocked'));
      expect(
        workflow,
        contains('Stable release gate correctly remains closed'),
      );
    });

"""
if marker not in integrity:
    raise SystemExit("Could not locate repository-integrity insertion point")
integrity = integrity.replace(marker, new_tests + marker, 1)
write(integrity_path, integrity)

replace_required(
    "windows/runner/Runner.rc",
    "#define VERSION_AS_NUMBER 1,0,0,0",
    "#define VERSION_AS_NUMBER 1,5,0,15",
    1,
)
replace_required(
    "windows/runner/Runner.rc",
    '#define VERSION_AS_STRING "1.0.0"',
    '#define VERSION_AS_STRING "1.5.0"',
    1,
)

readme_path = "README.md"
readme = read(readme_path)
old = "The repository is currently on the **`0.9.0+1` release-candidate line**. Automated quality and native build evidence is documented, while physical-device, real screen-reader, signing/provisioning, long-session, and store-release qualification remain explicit manual boundaries before a stable 1.0.0 claim."
new = "The repository is currently on the **`1.5.0+15` Version 1.5 line**. Automated quality and native build evidence remains required, while physical-device, real screen-reader, signing/provisioning, long-session, and store-release qualification stay explicit manual boundaries before a qualified stable-release claim."
if old not in readme:
    raise SystemExit("README current-version paragraph not found")
readme = readme.replace(old, new, 1)
old = "Release promotion is now fail-closed: `dart run tool/release_readiness.dart` validates candidate metadata and the evidence manifest, while `dart run tool/release_readiness.dart --stable` refuses promotion until the package is actually `1.0.0`, the changelog has a stable release section, and every required real-world qualification item has recorded passed evidence. See [`docs/RELEASE_QUALIFICATION.md`](docs/RELEASE_QUALIFICATION.md)."
new = "Release promotion remains fail-closed: `dart run tool/release_readiness.dart` validates Version 1.5 candidate metadata and the evidence manifest, while `dart run tool/release_readiness.dart --stable` refuses promotion until the package is the `1.5.0` stable target, the changelog has a matching stable release section, and every required real-world qualification item has recorded passed evidence. See [`docs/RELEASE_QUALIFICATION.md`](docs/RELEASE_QUALIFICATION.md)."
if old not in readme:
    raise SystemExit("README stable-gate paragraph not found")
write(readme_path, readme.replace(old, new, 1))

roadmap_path = "ROADMAP.md"
roadmap = read(roadmap_path)
for old, new in [
    ("## 0.9.x — Release-candidate hardening", "## 1.5.x — Current Version 1.5 hardening"),
    ("Remaining release qualification before `1.0.0`", "Remaining release qualification before `1.5.0`"),
    ("## 1.0.0 — First stable release", "## 1.5.0 — Qualified stable release target"),
    ("`1.0.0`", "`1.5.0`"),
]:
    if old not in roadmap:
        raise SystemExit(f"Expected roadmap text not found: {old!r}")
    roadmap = roadmap.replace(old, new)
write(roadmap_path, roadmap)

qualification_path = "docs/RELEASE_QUALIFICATION.md"
qualification = read(qualification_path)
qualification = qualification.replace("`1.0.0`", "`1.5.0`")
qualification = qualification.replace("[1.0.0]", "[1.5.0]")
qualification = qualification.replace("`0.9.x`", "`1.5.x`")
qualification = qualification.replace("0.9.x release-candidate line", "1.5.x current Version 1.5 line")
qualification = qualification.replace(
    "The live candidate still reports **0/13** real-world qualification items complete",
    "The live Version 1.5 candidate still reports **0/13** real-world qualification items complete",
)
write(qualification_path, qualification)

for path in ["docs/RELEASE_GATE_TESTING.md", "docs/RELEASE_CHECKLIST.md"]:
    text = read(path)
    text = text.replace("0.9.0+1", "1.5.0+15")
    text = text.replace("0.9.x", "1.5.x")
    text = text.replace("1.0.0", "1.5.0")
    write(path, text)

changelog_path = "CHANGELOG.md"
changelog = read(changelog_path)
added_marker = "### Added\n"
if added_marker not in changelog:
    raise SystemExit("CHANGELOG Added section not found")
changelog = changelog.replace(
    added_marker,
    added_marker
    + "- Version 1.5 package/runtime metadata (`1.5.0+15`) with regression coverage that keeps the runtime marketing version synchronized with `pubspec.yaml`.\n"
    + "- Version 1.5 release-gate regression coverage rejecting legacy 0.9 candidates while preserving fail-closed manual qualification.\n",
    1,
)
first_fixed = """### Fixed
- Missing Cupertino icon-font asset in Web release builds by explicitly pinning `cupertino_icons 1.0.8`; CI now fails if the missing-font warning returns.
- Generated macOS `file_picker` registration so Game Backup file transport has the expected native plugin registration on macOS.

"""
if first_fixed not in changelog:
    raise SystemExit("Expected duplicate early Fixed section not found")
changelog = changelog.replace(first_fixed, "", 1)
second_fixed = "### Fixed\n- Prevented directional engine write logic from falling through switch cases.\n"
merged_fixed = """### Fixed
- Removed release automation assumptions that treated every non-0.9 version as already stable-qualified; candidate CI is now independent from real-device stable qualification while the strict stable gate remains fail-closed.
- Missing Cupertino icon-font asset in Web release builds by explicitly pinning `cupertino_icons 1.0.8`; CI now fails if the missing-font warning returns.
- Generated macOS `file_picker` registration so Game Backup file transport has the expected native plugin registration on macOS.
- Prevented directional engine write logic from falling through switch cases.
"""
if second_fixed not in changelog:
    raise SystemExit("Main CHANGELOG Fixed section not found")
changelog = changelog.replace(second_fixed, merged_fixed, 1)
changed_marker = "### Changed\n"
if changed_marker not in changelog:
    raise SystemExit("CHANGELOG Changed section not found")
changelog = changelog.replace(
    changed_marker,
    changed_marker
    + "- The maintained package line is now Version 1.5 (`1.5.0+15` candidate metadata, `1.5.0` marketing version) with the qualification manifest and release policy aligned to the same target.\n"
    + "- Windows version-resource fallback metadata now matches Version 1.5 instead of the old template fallback.\n",
    1,
)
write(changelog_path, changelog)
