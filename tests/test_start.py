import os
from pathlib import Path
import subprocess
import tempfile
import unittest


START_SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "start.sh"
START_SETTINGS = (
    "SERVER_PORT", "PUBLIC_IP", "PUBLIC_PORT", "MAX_PLAYERS",
    "WORKER_THREADS", "ENABLE_MULTITHREADING", "PUBLIC_LOBBY",
    "LOG_FORMAT", "ENABLE_GAMEDATA_API",
)
MULTITHREAD_ARGS = (
    "-useperfthreads", "-NoAsyncLoadingThread", "-UseMultithreadForDS",
)


class StartScriptTests(unittest.TestCase):
    def run_server(self, **settings):
        with tempfile.TemporaryDirectory() as directory:
            server_dir = Path(directory)
            launcher = server_dir / "PalServer.sh"
            launcher.write_text(
                '#!/bin/bash\nprintf \'%s\\0\' "$@" > "$ARGS_OUTPUT_FILE"\n'
            )
            launcher.chmod(0o755)
            output_file = server_dir / "args"
            environment = os.environ.copy()
            for setting in START_SETTINGS:
                environment.pop(setting, None)
            environment.update(
                SERVER_DIR=directory, ARGS_OUTPUT_FILE=str(output_file), **settings
            )
            result = subprocess.run(
                ["bash", str(START_SCRIPT)], env=environment,
                capture_output=True, text=True, timeout=10,
            )
            arguments = None
            if output_file.exists():
                arguments = output_file.read_bytes().decode().rstrip("\0").split("\0")
            return result, arguments

    def test_default_launch_uses_game_threading_and_network_detection(self):
        result, arguments = self.run_server()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(arguments, ["-port=8211", "-players=16", "-logformat=text"])

    def test_multithreading_can_be_enabled_with_or_without_worker_count(self):
        for worker_count in ("", "4"):
            with self.subTest(worker_count=worker_count):
                result, arguments = self.run_server(
                    ENABLE_MULTITHREADING="true", WORKER_THREADS=worker_count,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                for argument in MULTITHREAD_ARGS:
                    self.assertIn(argument, arguments)
                worker_args = [a for a in arguments if a.startswith("-NumberOfWorkerThreadsServer=")]
                self.assertEqual(worker_args, ["-NumberOfWorkerThreadsServer=4"] if worker_count else [])

    def test_gamedata_api_is_independent_of_multithreading(self):
        result, arguments = self.run_server(ENABLE_GAMEDATA_API="true")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("-enable-gamedata-api", arguments)
        for argument in MULTITHREAD_ARGS:
            self.assertNotIn(argument, arguments)

    def test_custom_arguments_and_both_features_can_be_combined(self):
        result, arguments = self.run_server(
            SERVER_PORT="9000", MAX_PLAYERS="32", PUBLIC_LOBBY="true",
            PUBLIC_IP="203.0.113.10", PUBLIC_PORT="19000", LOG_FORMAT="json",
            ENABLE_MULTITHREADING="true", WORKER_THREADS="8",
            ENABLE_GAMEDATA_API="true",
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertCountEqual(arguments, [
            *MULTITHREAD_ARGS, "-NumberOfWorkerThreadsServer=8",
            "-port=9000", "-players=32", "-publiclobby",
            "-publicip=203.0.113.10", "-publicport=19000", "-logformat=json",
            "-enable-gamedata-api",
        ])

    def test_worker_count_requires_multithreading(self):
        result, arguments = self.run_server(WORKER_THREADS="4")
        self.assertEqual(result.returncode, 1)
        self.assertIsNone(arguments)
        self.assertIn("ENABLE_MULTITHREADING=true", result.stdout)

    def test_invalid_worker_counts_do_not_launch_game(self):
        for worker_count in ("0", "-1", "1.5", "abc", "4 -port=9000"):
            with self.subTest(worker_count=worker_count):
                result, arguments = self.run_server(
                    ENABLE_MULTITHREADING="true", WORKER_THREADS=worker_count,
                )
                self.assertEqual(result.returncode, 1)
                self.assertIsNone(arguments)
                self.assertIn("WORKER_THREADS", result.stdout)

    def test_invalid_feature_switches_do_not_launch_game(self):
        for setting in ("ENABLE_MULTITHREADING", "ENABLE_GAMEDATA_API"):
            for value in ("TRUE", "yes"):
                with self.subTest(setting=setting, value=value):
                    result, arguments = self.run_server(**{setting: value})
                    self.assertEqual(result.returncode, 1)
                    self.assertIsNone(arguments)
                    self.assertIn(setting, result.stdout)


if __name__ == "__main__":
    unittest.main()
