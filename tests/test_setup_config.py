import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SETUP_SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "setup_config.sh"
OFFICIAL_CONFIG = (
    '[/Script/Pal.PalGameWorldSettings]\n'
    'OptionSettings=(ServerName="Default Palworld Server")\n'
)


class SetupConfigTests(unittest.TestCase):
    def run_setup(
        self, config=None, official=OFFICIAL_CONFIG, confirmed=True,
        skip_confirmation=True,
    ):
        with tempfile.TemporaryDirectory() as directory:
            server_dir = Path(directory)
            config_dir = server_dir / "Pal/Saved/Config/LinuxServer"
            config_dir.mkdir(parents=True)
            config_file = config_dir / "PalWorldSettings.ini"
            if config is not None:
                config_file.write_text(config)
            if official is not None:
                (server_dir / "DefaultPalWorldSettings.ini").write_text(official)
            if confirmed:
                (config_dir / "ConfigConfirmed.ini").write_text("CONFIG_CONFIRMED=true\n")
            environment = dict(
                os.environ, SERVER_DIR=directory,
                SKIP_CONFIG_WAIT="true" if skip_confirmation else "false",
            )
            result = subprocess.run(
                ["bash", str(SETUP_SCRIPT)], env=environment,
                capture_output=True, text=True, timeout=3,
            )
            content = config_file.read_text() if config_file.exists() else None
            confirmation_file = config_dir / "ConfigConfirmed.ini"
            confirmation = confirmation_file.read_text() if confirmation_file.exists() else None
            return result, content, confirmation

    def test_missing_or_blank_config_is_initialized_even_when_confirmed(self):
        for config in (None, "", "\n", " \t\r\n"):
            with self.subTest(config=config):
                result, content, confirmation = self.run_setup(config=config)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(content, OFFICIAL_CONFIG)
                self.assertIn("\nCONFIG_CONFIRMED=true\n", confirmation)

    def test_custom_config_is_preserved_with_or_without_confirmation(self):
        config = OFFICIAL_CONFIG.replace("Default Palworld Server", "我的服务器")
        for confirmed in (False, True):
            with self.subTest(confirmed=confirmed):
                result, content, _ = self.run_setup(config=config, confirmed=confirmed)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(content, config)

    def test_missing_or_blank_template_does_not_replace_existing_empty_config(self):
        for official in (None, "", " \t\n"):
            with self.subTest(official=official):
                result, content, _ = self.run_setup(config="\n", official=official)
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertEqual(content, "\n")
                self.assertIn("官方配置文件", result.stdout)

    def test_confirmed_custom_config_does_not_require_template(self):
        result, content, _ = self.run_setup(
            config=OFFICIAL_CONFIG, official=None, skip_confirmation=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(content, OFFICIAL_CONFIG)

    def test_unconfirmed_config_exits_immediately_without_polling(self):
        for config in (None, OFFICIAL_CONFIG):
            with self.subTest(config=config):
                result, content, confirmation = self.run_setup(
                    config=config, confirmed=False, skip_confirmation=False,
                )
                self.assertEqual(result.returncode, 78, result.stdout + result.stderr)
                self.assertEqual(content, OFFICIAL_CONFIG)
                self.assertIn("\nCONFIG_CONFIRMED=false\n", confirmation)

    def test_restoring_blank_config_requires_confirmation_again(self):
        result, content, confirmation = self.run_setup(
            config="\n", confirmed=True, skip_confirmation=False,
        )
        self.assertEqual(result.returncode, 78, result.stdout + result.stderr)
        self.assertEqual(content, OFFICIAL_CONFIG)
        self.assertIn("\nCONFIG_CONFIRMED=false\n", confirmation)


if __name__ == "__main__":
    unittest.main()
