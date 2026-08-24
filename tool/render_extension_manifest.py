import argparse
import json
import sys
from pathlib import Path

PLANNED_VERSION = "2.1.0"
TEMPLATES = {
    "chromium": "extension/manifests/chromium/manifest.template.json",
    "firefox": "extension/manifests/firefox/manifest.template.json",
}
FORBIDDEN_KEYS = ("permissions", "host_permissions", "content_scripts")
FIREFOX_PLACEHOLDER = "__FIREFOX_EXTENSION_ID__"


def load_template(root: Path, browser: str) -> dict:
    relative = TEMPLATES[browser]
    path = root / relative
    if not path.is_file():
        raise ValueError(f"Manifest template is missing: {relative}")
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ValueError(f"Invalid JSON in {relative}: {error.msg}") from error
    if not isinstance(value, dict):
        raise ValueError(f"{relative} must contain a JSON object.")
    return value


def validate_template(browser: str, manifest: dict) -> None:
    if manifest.get("manifest_version") != 3:
        raise ValueError("Extension manifest must use Manifest V3.")
    if manifest.get("version") != PLANNED_VERSION:
        raise ValueError(f"Extension manifest version must be {PLANNED_VERSION}.")
    action = manifest.get("action")
    if not isinstance(action, dict) or action.get("default_popup") != "index.html":
        raise ValueError(
            "Extension manifest must use index.html as the bounded action popup."
        )
    for key in FORBIDDEN_KEYS:
        if key in manifest:
            raise ValueError(f"Preparation manifest must not declare {key}.")

    settings = manifest.get("browser_specific_settings")
    if browser == "chromium":
        if settings is not None:
            raise ValueError(
                "Chromium manifest must not contain Firefox-specific settings."
            )
        return

    gecko = settings.get("gecko") if isinstance(settings, dict) else None
    if not isinstance(gecko, dict):
        raise ValueError("Firefox manifest must contain browser_specific_settings.gecko.")
    if gecko.get("id") != FIREFOX_PLACEHOLDER:
        raise ValueError("Firefox template must retain the non-release ID placeholder.")
    data = gecko.get("data_collection_permissions")
    required = data.get("required") if isinstance(data, dict) else None
    if required != ["none"]:
        raise ValueError(
            "Firefox preparation manifest must declare required data collection as none."
        )


def render_manifest(root: Path, browser: str, firefox_id: str | None) -> dict:
    manifest = load_template(root, browser)
    validate_template(browser, manifest)

    if browser == "firefox":
        if firefox_id is None or not firefox_id.strip():
            raise ValueError(
                "--firefox-id is required when rendering the Firefox manifest."
            )
        if any(character.isspace() for character in firefox_id):
            raise ValueError("--firefox-id must not contain whitespace.")
        manifest["browser_specific_settings"]["gecko"]["id"] = firefox_id.strip()
    elif firefox_id is not None:
        raise ValueError("--firefox-id is only valid with --browser=firefox.")

    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Render a 2048 Nova 2.1.0 preparation manifest from a reviewed template."
        )
    )
    parser.add_argument("--browser", choices=sorted(TEMPLATES), required=True)
    parser.add_argument("--root", default=".", help="Repository root.")
    parser.add_argument("--output", required=True, help="Manifest output path.")
    parser.add_argument(
        "--firefox-id",
        help="Firefox extension ID used only for Firefox output.",
    )
    args = parser.parse_args()

    root_value = args.root.strip()
    output_value = args.output.strip()
    if not root_value:
        parser.error("--root requires a non-empty value.")
    if not output_value:
        parser.error("--output requires a non-empty value.")

    root = Path(root_value).resolve()
    if not root.is_dir():
        print(f"Repository root does not exist: {root}", file=sys.stderr)
        return 1

    try:
        manifest = render_manifest(root, args.browser, args.firefox_id)
    except ValueError as error:
        print(str(error), file=sys.stderr)
        return 1

    output = Path(output_value)
    if not output.is_absolute():
        output = (Path.cwd() / output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
