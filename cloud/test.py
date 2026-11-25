"""Test bootstrap control flow and validate the rendered provider files."""

import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

import yaml

CLOUD = Path(__file__).resolve().parent
CONFIG = Path(sys.argv.pop(1)).resolve()
REVISION = "a" * 40


class ConfigTests(unittest.TestCase):
    def test_provider_files(self):
        for provider, path in (
            ("codex", ".agents/skills"),
            ("claude", ".claude/skills"),
            ("cursor", ".cursor/skills"),
        ):
            skills = CONFIG / provider / path
            self.assertEqual(
                {file.parent.name for file in skills.glob("*/SKILL.md")},
                {"conventional-commits", "home-manager-modules", "nix-flakes"},
            )
            for skill in skills.glob("*/SKILL.md"):
                frontmatter = yaml.safe_load(skill.read_text().split("---", 2)[1])
                self.assertEqual(frontmatter["name"], skill.parent.name)
                self.assertIsInstance(frontmatter["description"], str)
        for item in (CONFIG / "claude/.claude/agents").glob("*.md"):
            meta = yaml.safe_load(item.read_text().split("---", 2)[1])
            self.assertEqual(meta["name"], item.stem)
            self.assertIsInstance(meta["tools"], str)
        for item in (CONFIG / "claude/.claude/commands").glob("*.md"):
            meta = yaml.safe_load(item.read_text().split("---", 2)[1])
            self.assertIsInstance(meta["description"], str)
            if "argument-hint" in meta:
                self.assertIsInstance(meta["argument-hint"], str)
        rule = CONFIG / "cursor/.cursor/rules/ai-nixcfg.mdc"
        self.assertIs(yaml.safe_load(rule.read_text().split("---", 2)[1])["alwaysApply"], True)
        settings = json.loads((CONFIG / "claude/.claude/settings.json").read_text())
        self.assertEqual(set(settings["permissions"]), {"deny"})
        self.assertIn("Read(./.env)", settings["permissions"]["deny"])
        self.assertEqual(set(settings["hooks"]), {"SessionStart"})
        mcp = json.loads((CONFIG / "optional/claude/.mcp.json").read_text())["mcpServers"]
        cursor = json.loads((CONFIG / "optional/cursor/deepwiki.json").read_text())
        self.assertEqual(mcp, {"deepwiki": {"type": "http", "url": cursor["url"]}})
        self.assertTrue(cursor["url"].startswith("https://"))
        cursor_environment = json.loads((CLOUD / "cursor-environment.json").read_text())
        self.assertEqual(cursor_environment, {"install": "bash .cursor/ai-nixcfg-setup.sh"})
        for file in CONFIG.rglob("*"):
            if file.is_file():
                for forbidden in ("127.0.0.1", "/Users/div", "~/Projects", "GH_TOKEN=", "api_key"):
                    self.assertNotIn(forbidden, file.read_text())

    def test_claude_session_hook(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            env = dict(os.environ, HOME=tmp)
            script = CONFIG / "claude/.claude/ai-nixcfg-session.sh"
            subprocess.run(["bash", script], env=env, check=True)
            env_file = home / ".local/state/ai-nixcfg-cloud/env"
            env_file.parent.mkdir(parents=True)
            env_file.write_text("export CLOUD_HOOK_TEST=loaded\n")
            startup = home / "session.env"
            env.update(CLAUDE_CODE_REMOTE="true", CLAUDE_ENV_FILE=str(startup))
            subprocess.run(["bash", script], env=env, check=True)
            result = subprocess.check_output(
                ["bash", "-c", 'source "$1"; printf %s "$CLOUD_HOOK_TEST"', "bash", startup],
                env=env,
                text=True,
            )
            self.assertEqual(result, "loaded")


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        context = tempfile.TemporaryDirectory()
        self.addCleanup(context.cleanup)
        self.root = Path(context.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.result = self.root / "result"
        (self.result / "bin").mkdir(parents=True)
        self.state = self.root / ".local/state/ai-nixcfg-cloud"
        self.env = dict(os.environ, HOME=str(self.root), PATH=f"{self.bin}:{os.environ['PATH']}")
        self.stub("uname", 'case "$1" in -s) echo "${TEST_OS:-Linux}";; -m) echo "${TEST_ARCH:-x86_64}";; esac')
        self.stub("nix", """
if [[ $1 == store ]]; then exit "${TEST_PING_STATUS:-0}"; fi
printf '%s\\n' "$*" >> "$HOME/nix.log"
while [[ $1 != --out-link ]]; do shift; done
if [[ ${TEST_BUILD_STATUS:-0} != 0 ]]; then exit "$TEST_BUILD_STATUS"; fi
ln -s "$HOME/result" "$2"
""")
        self.stub("nix-store", "exit 99")
        self.stub("curl", "exit 7")
        if not shutil.which("flock"):
            self.stub("flock", "exit 0")
        (self.result / "profile").write_text("x86_64-linux\ncore\n")
        (self.result / "tools").write_text("nix\n")
        (self.result / "config").symlink_to(CONFIG)
        self.write_script(self.result / "bin/nix", '[[ $1 == --version ]]')
        shutil.copyfile(CLOUD / "smoke.sh", self.result / "smoke.sh")

    def write_script(self, path, script):
        path.write_text("#!/usr/bin/env bash\nset -euo pipefail\n" + script + "\n")
        path.chmod(0o755)

    def stub(self, name, script):
        self.write_script(self.bin / name, script)

    def provision(self, *args, **overrides):
        return subprocess.run(
            ["bash", CLOUD / "bootstrap.sh", *args],
            env=self.env | overrides,
            capture_output=True,
            text=True,
        )

    def test_pinning_and_repeated_setup(self):
        for provider in ("codex", "cursor", "claude"):
            result = self.provision(provider, REVISION)
            self.assertEqual(result.returncode, 0, result.stderr)
        lines = (self.root / "nix.log").read_text().splitlines()
        self.assertEqual(len(lines), 1)
        self.assertIn(f"github:DivitMittal/ai-nixCfg/{REVISION}#packages.x86_64-linux.cloud-agent-tools", lines[0])
        self.assertEqual((self.state / "current/revision").read_text().strip(), REVISION)
        self.assertEqual((self.root / ".bashrc").read_text().count("# ai-nixCfg cloud toolchain"), 1)

    def test_arm_and_infra(self):
        (self.result / "profile").write_text("aarch64-linux\ninfra\n")
        for arch in ("aarch64", "arm64"):
            result = self.provision("codex", REVISION, "infra", TEST_ARCH=arch)
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("#packages.aarch64-linux.cloud-agent-tools-infra", (self.root / "nix.log").read_text())

    def test_unsupported_platform_and_revision(self):
        cases = (
            (("codex", "main"), {}, "commit SHA"),
            (("codex", REVISION), {"TEST_OS": "Darwin"}, "Unsupported platform"),
            (("codex", REVISION), {"TEST_ARCH": "i686"}, "Unsupported platform"),
            (("codex", REVISION, "bogus"), {}, "Choose core or infra"),
        )
        for args, overrides, message in cases:
            result = self.provision(*args, **overrides)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(message, result.stderr)
        self.assertFalse(self.state.exists())

    def test_failed_refresh_preserves_active_profile(self):
        result = self.provision("claude", REVISION)
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.provision("claude", "b" * 40, TEST_BUILD_STATUS="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Pinned flake build failed", result.stderr)
        self.assertEqual((self.state / "current/revision").read_text().strip(), REVISION)

    def test_permissions_and_missing_tools(self):
        result = self.provision("codex", REVISION, TEST_PING_STATUS="1")
        self.assertIn("store is unavailable", result.stderr)
        self.assertNotEqual(result.returncode, 0)
        (self.result / "bin/nix").unlink()
        result = self.provision("codex", REVISION)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("verification failed", result.stderr)
        self.assertFalse((self.state / "current").exists())

    def test_artifact_failure_modes(self):
        url = "https://example.invalid/cloud.gz"
        result = self.provision("claude", REVISION, "core", url, "0" * 64)
        self.assertIn("Download failed", result.stderr)
        self.stub("curl", 'while [[ $1 != --output ]]; do shift; done; printf garbage > "$2"')
        result = self.provision("claude", REVISION, "core", url, "0" * 64)
        self.assertIn("SHA-256 verification failed", result.stderr)
        payload = gzip.compress(b"ai-nixcfg-cloud-v1 wrong x86_64-linux core /nix/store/test\n")
        (self.root / "payload").write_bytes(payload)
        self.stub("curl", 'while [[ $1 != --output ]]; do shift; done; cp "$HOME/payload" "$2"')
        result = self.provision("claude", REVISION, "core", url, hashlib.sha256(payload).hexdigest())
        self.assertIn("Closure metadata does not match", result.stderr)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.state / "current").exists())

    def test_missing_dependency(self):
        bash = shutil.which("bash")
        result = subprocess.run(
            [bash, CLOUD / "bootstrap.sh", "codex", REVISION],
            env={"HOME": str(self.root), "PATH": str(self.root / "empty")},
            capture_output=True,
            text=True,
        )
        self.assertIn("Missing required command: uname", result.stderr)
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
