"""Apply a declarative overlay without freezing Jcode's writable config."""

import os
import sys
import tempfile
from collections.abc import Mapping, MutableMapping
from pathlib import Path

import tomlkit


def merge(current, declared):
    for key, value in declared.items():
        old = current.get(key)
        if isinstance(old, MutableMapping) and isinstance(value, Mapping):
            merge(old, value)
        elif key not in current or type(old) is not type(value) or old != value:
            current[key] = value


def apply(overlay, target):
    if target.is_symlink():
        raise ValueError(f"refusing to replace symlink {target}; use a writable file")
    try:
        original = target.read_bytes().decode("utf-8")
    except FileNotFoundError:
        original = ""
    current = tomlkit.parse(original)
    merge(current, tomlkit.parse(overlay.read_text(encoding="utf-8")))
    rendered = tomlkit.dumps(current)
    if rendered == original:
        return

    target.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=target.parent, prefix=".config.toml.")
    try:
        mode = target.stat().st_mode & 0o777 if target.exists() else 0o600
        os.fchmod(fd, mode)
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as handle:
            handle.write(rendered)
        os.replace(temporary, target)
    finally:
        Path(temporary).unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        apply(Path(sys.argv[1]), Path(sys.argv[2]))
    except (OSError, ValueError, tomlkit.exceptions.TOMLKitError) as exc:
        sys.exit(f"Jcode settings activation failed: {exc}")
