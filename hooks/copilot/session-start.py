#!/usr/bin/env python3

from __future__ import annotations

import json
import sys
from pathlib import Path


def read_using_superpowers(plugin_root: Path) -> str:
    skill_path = plugin_root / "skills" / "using-superpowers" / "SKILL.md"
    try:
        return skill_path.read_text(encoding="utf-8")
    except OSError as error:
        return f"Error reading using-superpowers skill: {error}"


def build_context(plugin_root: Path) -> str:
    using_superpowers = read_using_superpowers(plugin_root)
    warning = ""
    legacy_skills_dir = Path.home() / ".config" / "superpowers" / "skills"

    if legacy_skills_dir.is_dir():
        warning = (
            "\n\n<important-reminder>"
            "WARNING: Superpowers now uses the skills installed with the plugin. "
            "Custom skills in ~/.config/superpowers/skills will not be read. "
            "Move any local skills into the plugin's skills directory."
            "</important-reminder>"
        )

    return (
        "<EXTREMELY_IMPORTANT>\n"
        "You have superpowers.\n\n"
        "**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. "
        "For all other skills, use the Skill tool:**\n\n"
        f"{using_superpowers}\n\n"
        f"{warning}\n"
        "</EXTREMELY_IMPORTANT>"
    )


def main() -> int:
    plugin_root = Path(__file__).resolve().parents[2]
    payload = {
        "additionalContext": build_context(plugin_root),
    }

    json.dump(payload, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())