import argparse
import json
import sys
from pathlib import Path

EXPECTED_CURRENT_PACKAGE = "2.0.12+2012"
EXPECTED_CURRENT_MARKETING = "2.0.12"
EXPECTED_NEXT_MARKETING = "2.1.0"
EXPECTED_TARGETS = ["Android", "iOS", "Web/PWA", "Windows", "macOS", "Linux"]


def read_text(root: Path, relative: str, failures: list[str]) -> str | None:
    path = root / relative
    if not path.is_file():
        failures.append(f"Required preparation file is missing: {relative}")
        return None
    try:
        return path.read_text(encoding="utf-8")
    except OSError as error:
        failures.append(f"Could not read {relative}: {error}")
        return None


def read_json(root: Path, relative: str, failures: list[str]) -> dict | None:
    text = read_text(root, relative, failures)
    if text is None:
        return None
    try:
        value = json.loads(text)
    except json.JSONDecodeError as error:
        failures.append(f"Invalid JSON in {relative}: {error.msg}")
        return None
    if not isinstance(value, dict):
        failures.append(f"{relative} must contain a JSON object.")
        return None
    return value


def audit_contract(root: Path, failures: list[str]) -> dict | None:
    contract = read_json(root, "tool/next_version_contract.json", failures)
    if contract is None:
        return None

    if contract.get("schemaVersion") != 1:
        failures.append("Next-version contract schemaVersion must be 1.")
    if contract.get("status") != "planned":
        failures.append(
            'Next-version contract status must remain "planned" during preparation.'
        )

    current = contract.get("currentRelease")
    if not isinstance(current, dict):
        failures.append("next_version_contract currentRelease must be an object.")
    else:
        if current.get("marketingVersion") != EXPECTED_CURRENT_MARKETING:
            failures.append(
                f"Current marketing version must remain {EXPECTED_CURRENT_MARKETING} during preparation."
            )
        if current.get("packageVersion") != EXPECTED_CURRENT_PACKAGE:
            failures.append(
                f"Current package version must remain {EXPECTED_CURRENT_PACKAGE} during preparation."
            )
        if current.get("manualQualificationPassed") != 0:
            failures.append(
                "Preparation must not fabricate passed Version 2.0.12 manual evidence."
            )
        if current.get("manualQualificationTotal") != 13:
            failures.append("Current manual qualification total must remain 13.")

    next_release = contract.get("nextRelease")
    if not isinstance(next_release, dict):
        failures.append("next_version_contract nextRelease must be an object.")
    else:
        if next_release.get("marketingVersion") != EXPECTED_NEXT_MARKETING:
            failures.append(
                f"Planned next marketing version must be {EXPECTED_NEXT_MARKETING}."
            )
        if next_release.get("packageVersion") is not None:
            failures.append("Next package version must remain null until activation.")
        if next_release.get("activationState") != "preparation-only":
            failures.append('Next activationState must remain "preparation-only".')

    migration_paths = contract.get("migrationPaths")
    if not isinstance(migration_paths, list) or not migration_paths:
        failures.append("Next-version migrationPaths must be a non-empty array.")
    else:
        for relative in migration_paths:
            if not isinstance(relative, str) or not relative.strip():
                failures.append("Every migrationPaths entry must be a non-empty string.")
                continue
            if not (root / relative).exists():
                failures.append(f"Migration path does not exist: {relative}")

    extension = contract.get("extensionFoundation")
    if not isinstance(extension, dict):
        failures.append("next_version_contract extensionFoundation must be an object.")
    else:
        if extension.get("status") != "design-prepared-source-not-activated":
            failures.append("Extension foundation must remain preparation-only.")
        if extension.get("chromiumManifest") != 3:
            failures.append("Chromium extension preparation must target Manifest V3.")
        if extension.get("firefoxWebExtensions") is not True:
            failures.append("Firefox WebExtensions preparation must remain enabled.")
        if extension.get("defaultHostPermissions") != []:
            failures.append("Default extension host permissions must remain empty.")
        if extension.get("defaultBrowserPermissions") != []:
            failures.append("Default extension browser permissions must remain empty.")
        if extension.get("remoteExecutableCodeAllowed") is not False:
            failures.append("Remote executable code must remain disallowed.")
        if extension.get("contentScriptsByDefault") is not False:
            failures.append("Content scripts must remain disabled by default.")
        if extension.get("browsingDataCollection") is not False:
            failures.append("Browsing-data collection must remain disabled.")
        if extension.get("pageContentCollection") is not False:
            failures.append("Page-content collection must remain disabled.")
        for key in (
            "telemetryRequired",
            "cloudRequired",
            "accountsRequired",
            "advertisingRequired",
        ):
            if extension.get(key) is not False:
                failures.append(
                    f"{key} must remain false during extension preparation."
                )
        if extension.get("preserveTargets") != EXPECTED_TARGETS:
            failures.append(
                "Extension preparation must preserve the six maintained Flutter targets."
            )

    gates = contract.get("activationGates")
    if not isinstance(gates, list) or len(gates) < 8:
        failures.append(
            "Next-version activationGates must retain the preparation gate set."
        )

    return contract


def audit_current_identity(root: Path, failures: list[str]) -> None:
    pubspec = read_text(root, "pubspec.yaml", failures)
    if pubspec is not None:
        expected = f"version: {EXPECTED_CURRENT_PACKAGE}"
        if expected not in pubspec.splitlines():
            failures.append(
                f"pubspec.yaml must remain {EXPECTED_CURRENT_PACKAGE} during 2.1.0 preparation."
            )
        if "version: 2.1.0" in pubspec:
            failures.append("2.1.0 must not be activated by the preparation branch.")

    project_info = read_text(
        root,
        "lib/core/constants/project_info.dart",
        failures,
    )
    if project_info is not None and f"'{EXPECTED_CURRENT_MARKETING}'" not in project_info:
        failures.append(
            f"ProjectInfo marketing version must remain {EXPECTED_CURRENT_MARKETING} during preparation."
        )


def audit_manifest(
    root: Path,
    relative: str,
    failures: list[str],
    *,
    firefox: bool,
) -> None:
    manifest = read_json(root, relative, failures)
    if manifest is None:
        return

    if manifest.get("manifest_version") != 3:
        failures.append(f"{relative} must use manifest_version 3.")
    if manifest.get("version") != EXPECTED_NEXT_MARKETING:
        failures.append(
            f"{relative} template version must be {EXPECTED_NEXT_MARKETING}."
        )
    action = manifest.get("action")
    if not isinstance(action, dict) or action.get("default_popup") != "index.html":
        failures.append(f"{relative} must keep the bounded index.html action popup.")

    for privileged_key in ("permissions", "host_permissions", "content_scripts"):
        if privileged_key in manifest:
            failures.append(
                f"{relative} must not declare {privileged_key} during least-privilege preparation."
            )

    if firefox:
        settings = manifest.get("browser_specific_settings")
        gecko = settings.get("gecko") if isinstance(settings, dict) else None
        if not isinstance(gecko, dict):
            failures.append(f"{relative} must contain Firefox gecko settings.")
            return
        if gecko.get("id") != "__FIREFOX_EXTENSION_ID__":
            failures.append(
                f"{relative} must retain the non-release Firefox ID placeholder."
            )
        data = gecko.get("data_collection_permissions")
        required = data.get("required") if isinstance(data, dict) else None
        if required != ["none"]:
            failures.append(
                f"{relative} must declare required data collection as none."
            )
    elif "browser_specific_settings" in manifest:
        failures.append(
            f"{relative} must keep Firefox-specific metadata out of the Chromium template."
        )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate 2048 Nova 2.1.0 preparation."
    )
    parser.add_argument("--root", default=".", help="Repository root to audit.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    args = parser.parse_args()

    root_value = args.root.strip()
    failures: list[str] = []
    if not root_value:
        failures.append("The --root path requires a non-empty value.")
        root = Path.cwd()
    else:
        root = Path(root_value).resolve()

    if not root.is_dir():
        failures.append(f"Repository root does not exist: {root}")
    else:
        audit_contract(root, failures)
        audit_current_identity(root, failures)
        audit_manifest(
            root,
            "extension/manifests/chromium/manifest.template.json",
            failures,
            firefox=False,
        )
        audit_manifest(
            root,
            "extension/manifests/firefox/manifest.template.json",
            failures,
            firefox=True,
        )
        for relative in (
            "docs/NEXT_VERSION_README.md",
            "docs/NEXT_VERSION_2_1_0.md",
            "docs/NEXT_VERSION_MIGRATION_CHECKLIST.md",
            "docs/BROWSER_EXTENSION_FOUNDATION.md",
            "extension/README.md",
            "what_changed_2_1_0_preparation.md",
        ):
            read_text(root, relative, failures)

    result = {
        "schemaVersion": 1,
        "root": str(root),
        "currentPackageVersion": EXPECTED_CURRENT_PACKAGE,
        "plannedMarketingVersion": EXPECTED_NEXT_MARKETING,
        "activationState": "preparation-only",
        "preparationReady": not failures,
        "failureCount": len(failures),
        "failures": failures,
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print("2048 Nova 2.1.0 preparation preflight")
        print(f"Root: {root}")
        print(f"Preparation ready: {'yes' if not failures else 'no'}")
        if failures:
            print("Failures:")
            for failure in failures:
                print(f"- {failure}")

    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())
