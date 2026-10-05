import importlib.util
import os
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = REPO_ROOT / "scripts" / "update_manifest.py"


def load_update_manifest():
    spec = importlib.util.spec_from_file_location("update_manifest", MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class UpdateManifestTests(unittest.TestCase):
    def setUp(self):
        self.um = load_update_manifest()

    def test_release_version_must_match_script_version(self):
        os.environ["RELEASE_VERSION"] = "9.9.9"
        self.addCleanup(os.environ.pop, "RELEASE_VERSION", None)

        with self.assertRaisesRegex(RuntimeError, "release"):
            self.um.validate_release_version("1.4.0")

    def test_read_bskeytools_version(self):
        version = self.um.read_bskeytools_version()
        self.assertRegex(version, r"^\d+\.\d+\.\d+$")

    def test_read_bscleanvirus_version(self):
        version = self.um.read_bscleanvirus_version()
        self.assertRegex(version, r"^\d+\.\d+")

    def test_write_version_dat(self):
        with tempfile.NamedTemporaryFile(mode="r", suffix=".dat", delete=False) as tmp:
            tmp_path = tmp.name

        try:
            original = self.um.VERSION_DAT
            self.um.VERSION_DAT = tmp_path
            self.addCleanup(setattr, self.um, "VERSION_DAT", original)

            self.um.write_version_dat("1.4.0")

            with open(tmp_path, encoding="utf-8") as f:
                lines = f.read().splitlines()
            self.assertEqual(len(lines), 1)
            self.assertEqual(lines[0], "1.4.0")
        finally:
            os.unlink(tmp_path)

    def _temp_nsis(self, data: bytes) -> str:
        fd, path = tempfile.mkstemp(suffix=".nsi")
        with os.fdopen(fd, "wb") as f:
            f.write(data)
        self.addCleanup(os.unlink, path)
        original = self.um.NSIS_BSKT
        self.um.NSIS_BSKT = path
        self.addCleanup(setattr, self.um, "NSIS_BSKT", original)
        return path

    def test_nsis_update_keeps_bom_and_line_endings(self):
        body = '; 中文注释\r\nUnicode true\r\n!define PRODUCT_VERSION_NUM "1.0.0"\r\n'
        path = self._temp_nsis(b"\xef\xbb\xbf" + body.encode("utf-8"))

        self.um.update_bskeytools_nsis_version("2.3.4")

        with open(path, "rb") as f:
            data = f.read()
        expected = body.replace('"1.0.0"', '"2.3.4"')
        self.assertEqual(data, b"\xef\xbb\xbf" + expected.encode("utf-8"))

    def test_nsis_without_bom_is_rejected(self):
        self._temp_nsis(b'Unicode true\n!define PRODUCT_VERSION_NUM "1.0.0"\n')

        with self.assertRaisesRegex(RuntimeError, "BOM"):
            self.um.update_bskeytools_nsis_version("2.3.4")

    def test_nsis_invalid_utf8_is_rejected(self):
        self._temp_nsis(b'\xef\xbb\xbf; \xd6\xd0\xce\xc4\n!define PRODUCT_VERSION_NUM "1.0.0"\n')

        with self.assertRaises(UnicodeDecodeError):
            self.um.update_bskeytools_nsis_version("2.3.4")


if __name__ == "__main__":
    unittest.main()
