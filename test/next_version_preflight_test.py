import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tool" / "next_version_preflight.py"


class NextVersionPreflightTest(unittest.TestCase):
    def run_preflight(self, root: Path) -> tuple[subprocess.CompletedProcess[str], dict]:
        process = subprocess.run(
            [sys.executable, str(SCRIPT), "--root", str(root), "--json"],
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertTrue(process.stdout.strip(), process.stderr)
        return process, json.loads(process.stdout)

    def make_fixture(self) -> Path:
        temp = Path(tempfile.mkdtemp(prefix="nova-next-version-"))
        contract = json.loads(
            (ROOT / "tool" / "next_version_contract.json").read_text(encoding="utf-8")
        )
        required = set(contract["migrationPaths"])
        required.update(
            {
                "pubspec.yaml",
                "lib/core/constants/project_info.dart",
                "tool/next_version_contract.json",
                "extension/manifests/chromium/manifest.template.json",
                "extension/manifests/firefox/manifest.template.json",
                "docs/NEXT_VERSION_README.md",
                "docs/NEXT_VERSION_2_1_0.md",
                "docs/NEXT_VERSION_MIGRATION_CHECKLIST.md",
                "docs/BROWSER_EXTENSION_FOUNDATION.md",
                "extension/README.md",
                "what_changed_2_1_0_preparation.md",
            }
        )
        for relative in required:
            source = ROOT / relative
            target = temp / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            if source.is_file():
                shutil.copy2(source, target)
            elif source.is_dir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                self.fail(f"Preparation fixture source is missing: {relative}")
        self.addCleanup(shutil.rmtree, temp, ignore_errors=True)
        return temp

    def test_repository_preparation_contract_passes(self) -> None:
        process, output = self.run_preflight(ROOT)
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertTrue(output["preparationReady"])
        self.assertEqual(output["plannedMarketingVersion"], "2.1.0")
        self.assertEqual(output["activationState"], "preparation-only")
        self.assertEqual(output["failureCount"], 0)
        self.assertEqual(output["failures"], [])

    def test_permission_escalation_fails_closed(self) -> None:
        fixture = self.make_fixture()
        manifest_path = fixture / "extension/manifests/chromium/manifest.template.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        manifest["host_permissions"] = ["<all_urls>"]
        manifest_path.write_text(
            json.dumps(manifest, indent=2) + "\n",
            encoding="utf-8",
        )

        process, output = self.run_preflight(fixture)

        self.assertEqual(process.returncode, 1)
        self.assertFalse(output["preparationReady"])
        self.assertIn(
            "must not declare host_permissions",
            "\n".join(output["failures"]),
        )

    def test_premature_package_activation_fails_closed(self) -> None:
        fixture = self.make_fixture()
        pubspec = fixture / "pubspec.yaml"
        contents = pubspec.read_text(encoding="utf-8")
        pubspec.write_text(
            contents.replace("version: 2.0.12+2012", "version: 2.1.0+2100"),
            encoding="utf-8",
        )

        process, output = self.run_preflight(fixture)

        self.assertEqual(process.returncode, 1)
        self.assertFalse(output["preparationReady"])
        self.assertIn(
            "pubspec.yaml must remain 2.0.12+2012",
            "\n".join(output["failures"]),
        )

    def test_firefox_data_collection_drift_fails_closed(self) -> None:
        fixture = self.make_fixture()
        manifest_path = fixture / "extension/manifests/firefox/manifest.template.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        manifest["browser_specific_settings"]["gecko"][
            "data_collection_permissions"
        ]["required"] = ["technicalAndInteraction"]
        manifest_path.write_text(
            json.dumps(manifest, indent=2) + "\n",
            encoding="utf-8",
        )

        process, output = self.run_preflight(fixture)

        self.assertEqual(process.returncode, 1)
        self.assertFalse(output["preparationReady"])
        self.assertIn(
            "must declare required data collection as none",
            "\n".join(output["failures"]),
        )


if __name__ == "__main__":
    unittest.main()
