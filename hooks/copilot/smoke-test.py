#!/usr/bin/env python3

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def main() -> int:
    script_path = Path(__file__).resolve().parent / "session-start.py"
    plugin_root = script_path.parents[2]

    result = subprocess.run(
        [sys.executable, str(script_path)],
        check=False,
        capture_output=True,
        text=True,
        cwd=str(plugin_root),
    )

    if result.returncode != 0:
        print("smoke-test: session-start.py returned non-zero")
        print(result.stderr)
        return 1

    try:
        payload = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        print(f"smoke-test: invalid JSON output: {error}")
        return 1

    additional_context = payload.get("additionalContext")
    if not isinstance(additional_context, str):
        print("smoke-test: additionalContext missing or not a string")
        return 1

    required_snippets = [
        "You have superpowers.",
        "using-superpowers",
        "<EXTREMELY_IMPORTANT>",
    ]

    missing = [snippet for snippet in required_snippets if snippet not in additional_context]
    if missing:
        print("smoke-test: missing expected context snippets:")
        for snippet in missing:
            print(f"  - {snippet}")
        return 1

    print("smoke-test: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
