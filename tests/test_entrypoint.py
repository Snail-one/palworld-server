import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
OFFICIAL_CONFIG = (
    '[/Script/Pal.PalGameWorldSettings]\n'
    'OptionSettings=(ServerName="Default Palworld Server")\n'
)


class EntrypointTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        root = Path(self.directory.name)
        self.server_dir = root / "server"
        self.server_dir.mkdir()
        self.config_dir = self.server_dir / "Pal/Saved/Config/LinuxServer"
        self.config_dir.mkdir(parents=True)
        (self.server_dir / "DefaultPalWorldSettings.ini").write_text(OFFICIAL_CONFIG)
        self.marker = root / "game-started"
        launcher = self.server_dir / "PalServer.sh"
        launcher.write_text('#!/bin/bash\nprintf "started\\n" > "$LAUNCH_MARKER"\n')
        launcher.chmod(0o755)
        scripts_dir = root / "scripts"
        scripts_dir.mkdir()
        # 将容器的固定脚本目录映射到临时目录，其余入口逻辑保持不变。
        for name in ("entrypoint.sh", "setup_config.sh", "start.sh"):
            target = scripts_dir / name
            target.write_text(
                (SCRIPTS / name).read_text().replace("/scripts/", f"{scripts_dir}/")
            )
            target.chmod(0o755)
        self.entrypoint = scripts_dir / "entrypoint.sh"
        self.environment = dict(
            os.environ, SERVER_DIR=str(self.server_dir), CHECK_UPDATE="false",
            SKIP_CONFIG_WAIT="false", LAUNCH_MARKER=str(self.marker),
        )
        for name in (
            "SERVER_PORT", "PUBLIC_IP", "PUBLIC_PORT", "MAX_PLAYERS",
            "WORKER_THREADS", "ENABLE_MULTITHREADING", "PUBLIC_LOBBY",
            "LOG_FORMAT", "ENABLE_GAMEDATA_API",
        ):
            self.environment.pop(name, None)

    def run_entrypoint(self):
        return subprocess.run(
            ["bash", str(self.entrypoint)], env=self.environment,
            capture_output=True, text=True, timeout=3,
        )

    def test_first_launch_stops_then_manual_confirmation_allows_game_start(self):
        result = self.run_entrypoint()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse(self.marker.exists())
        config = self.config_dir / "PalWorldSettings.ini"
        self.assertEqual(config.read_text(), OFFICIAL_CONFIG)
        confirmation = self.config_dir / "ConfigConfirmed.ini"
        self.assertIn("\nCONFIG_CONFIRMED=false\n", confirmation.read_text())

        # 再次启动但仍未确认时，依然应正常停止。
        result = self.run_entrypoint()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse(self.marker.exists())

        custom = OFFICIAL_CONFIG.replace("Default Palworld Server", "Custom Server")
        config.write_text(custom)
        confirmation.write_text("CONFIG_CONFIRMED=true\n")
        result = self.run_entrypoint()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.marker.exists())
        self.assertEqual(config.read_text(), custom)

    def test_skip_confirmation_starts_game_on_first_launch(self):
        self.environment["SKIP_CONFIG_WAIT"] = "true"
        result = self.run_entrypoint()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.marker.exists())

    def test_setup_error_is_not_treated_as_normal_stop(self):
        (self.server_dir / "DefaultPalWorldSettings.ini").write_text("\n")
        result = self.run_entrypoint()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertFalse(self.marker.exists())


if __name__ == "__main__":
    unittest.main()
