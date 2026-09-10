import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tool" / "render_extension_manifest.py"


class ExtensionManifestRendererTest(unittest.TestCase):
    def run_renderer(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--root", str(ROOT), *args],
            check=False,
            capture_output=True,
            text=True,
        )

    def test_chromium_manifest_renders_without_privileged_keys(self) -> None:
        with tempfile.TemporaryDirectory(prefix="nova-chromium-manifest-") as temp:
            output = Path(temp) / "manifest.json"
            process = self.run_renderer(
                "--browser",
                "chromium",
                "--output",
                str(output),
            )

            self.assertEqual(process.returncode, 0, process.stderr)
            manifest = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(manifest["manifest_version"], 3)
            self.assertEqual(manifest["version"], "2.1.0")
            self.assertNotIn("permissions", manifest)
            self.assertNotIn("host_permissions", manifest)
            self.assertNotIn("content_scripts", manifest)
            self.assertNotIn("browser_specific_settings", manifest)

    def test_firefox_manifest_requires_explicit_id(self) -> None:
        with tempfile.TemporaryDirectory(prefix="nova-firefox-manifest-") as temp:
            output = Path(temp) / "manifest.json"
            process = self.run_renderer(
                "--browser",
                "firefox",
                "--output",
                str(output),
            )

            self.assertEqual(process.returncode, 1)
            self.assertIn("--firefox-id is required", process.stderr)
            self.assertFalse(output.exists())

    def test_firefox_manifest_replaces_non_release_id_placeholder(self) -> None:
        with tempfile.TemporaryDirectory(prefix="nova-firefox-manifest-") as temp:
            output = Path(temp) / "manifest.json"
            extension_id = "nova-2048@example.invalid"
            process = self.run_renderer(
                "--browser",
                "firefox",
                "--firefox-id",
                extension_id,
                "--output",
                str(output),
            )

            self.assertEqual(process.returncode, 0, process.stderr)
            manifest = json.loads(output.read_text(encoding="utf-8"))
            gecko = manifest["browser_specific_settings"]["gecko"]
            self.assertEqual(gecko["id"], extension_id)
            self.assertEqual(
                gecko["data_collection_permissions"]["required"],
                ["none"],
            )

    def test_firefox_id_is_rejected_for_chromium(self) -> None:
        with tempfile.TemporaryDirectory(prefix="nova-chromium-manifest-") as temp:
            output = Path(temp) / "manifest.json"
            process = self.run_renderer(
                "--browser",
                "chromium",
                "--firefox-id",
                "nova-2048@example.invalid",
                "--output",
                str(output),
            )

            self.assertEqual(process.returncode, 1)
            self.assertIn("--firefox-id is only valid", process.stderr)
            self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
