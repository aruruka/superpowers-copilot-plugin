# Manual Install: Superpowers for GitHub Copilot in VS Code

This path is for the Windows-side Copilot plugin store used by VS Code. It is separate from the native Superpowers installers for Claude Code, Cursor, and the CLI harnesses.

## What you install

You are not installing a package from a marketplace. You are placing a Superpowers plugin checkout in the Copilot plugin directory and registering it in the local plugin index.

## Exact steps

1. Close VS Code before editing the plugin registry.
2. Define your Windows plugin root (PowerShell):

```powershell
$PluginRoot = Join-Path $env:USERPROFILE ".vscode\agent-plugins\github.com\obra\superpowers"
New-Item -ItemType Directory -Path $PluginRoot -Force | Out-Null
```

3. Copy the contents of this repository into that folder.
4. Confirm the plugin manifest exists at `$PluginRoot\.github\plugin\plugin.json`.
5. Confirm the Copilot hook config exists at `$PluginRoot\hooks\hooks-copilot.json`.
6. Build a correctly encoded plugin URI from your actual path:

```powershell
$PluginUri = ([System.Uri]$PluginRoot).AbsoluteUri
$PluginUri
```

7. Open `%USERPROFILE%\.vscode\agent-plugins\installed.json` and add an entry like this:

```json
{
  "pluginUri": "<paste value from $PluginUri>",
  "marketplace": "obra/superpowers-marketplace"
}
```

8. Restart VS Code on Windows.
9. Open Copilot Chat and start a new session.
10. Ask for something that normally triggers Superpowers, such as a feature idea or a bug fix.
11. Confirm the session bootstrap content is loaded before implementation starts.

## Smoke test (recommended)

Run this from the installed plugin folder on Windows:

```powershell
cd $PluginRoot
py -3 .\hooks\copilot\smoke-test.py
```

Expected output:

```text
smoke-test: OK
```

If `py` is unavailable, use:

```powershell
python .\hooks\copilot\smoke-test.py
```

## Optional debug logging

If session-start bootstrap is not appearing, enable hook debug logging before launching VS Code.

PowerShell:

```powershell
$env:SUPERPOWERS_COPILOT_HOOK_DEBUG = Join-Path $env:TEMP "superpowers-copilot-hook.log"
```

Then start VS Code from the same shell and reproduce startup. Inspect the log:

```powershell
Get-Content $env:SUPERPOWERS_COPILOT_HOOK_DEBUG -Tail 50
```

When done, unset the variable:

```powershell
Remove-Item Env:SUPERPOWERS_COPILOT_HOOK_DEBUG
```

## File map

- `.github/plugin/plugin.json` - Copilot plugin manifest.
- `hooks/hooks-copilot.json` - Session-start hook registration.
- `hooks/copilot/run-hook.cmd` - Copilot session-start wrapper that resolves `py -3` or `python`.
- `hooks/copilot/session-start.py` - Python bootstrap that injects the `using-superpowers` skill into Copilot context.
- `hooks/copilot/smoke-test.py` - Local validation for hook output format and required context snippets.
- `skills/using-superpowers/SKILL.md` - Bootstrap skill content loaded at session start.
- `skills/*/SKILL.md` - Superpowers skills available to Copilot after install.
- `README.md` - Human-facing install entry point and harness list.

## Notes

- This skeleton uses a Python hook so the bootstrap logic is easy to maintain and does not depend on Bash on Windows.
- The hook reads the `using-superpowers` skill from the installed plugin checkout, so the repo copy on Windows must stay in sync with the files on disk.
- If you already keep a mirrored copy under another Copilot plugin directory, recompute `$PluginUri` from that folder instead of editing URI encoding manually.