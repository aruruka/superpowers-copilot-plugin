# Manual Install: Superpowers for GitHub Copilot in VS Code

This path is for the Windows-side Copilot plugin store used by VS Code. It is separate from the native Superpowers installers for Claude Code, Cursor, and the CLI harnesses.

This plugin is hook-free by design. SessionStart hooks are not required or registered.

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
4. Confirm the plugin manifest exists at `$PluginRoot\plugins\superpowers-copilot-plugin\.claude-plugin\plugin.json`.
5. Confirm skills exist under `$PluginRoot\plugins\superpowers-copilot-plugin\skills`.
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
10. Invoke this command first:

```text
/superpowers-copilot-plugin:using-superpowers
```

11. Then continue with your real task, for example:

```text
/superpowers-copilot-plugin:brainstorming
```

## Smoke test (recommended)

Run this inside a fresh Copilot chat session:

```text
/superpowers-copilot-plugin:using-superpowers
```

Expected outcome:

The response acknowledges the Superpowers skill system and workflow guidance.

Then run:

```text
/superpowers-copilot-plugin:brainstorming
```

The assistant should enter brainstorming workflow without any SessionStart warnings.

## Troubleshooting

If commands are not available in chat:

1. Confirm plugin is enabled in VS Code Plugins panel.
2. Reload window from command palette.
3. Reinstall from source `aruruka/superpowers-copilot-plugin`.
4. Ensure the installed plugin manifest has no `hooks` key.

If you still see SessionStart warnings, you likely have a stale installed plugin copy. Remove and reinstall the plugin.

## File map

- `plugins/superpowers-copilot-plugin/.claude-plugin/plugin.json` - Copilot plugin manifest (hook-free).
- `plugins/superpowers-copilot-plugin/skills/using-superpowers/SKILL.md` - Bootstrap guidance skill to run manually at thread start.
- `skills/*/SKILL.md` - Superpowers skills available to Copilot after install.
- `README.md` - Human-facing install entry point and harness list.

## Notes

- This plugin intentionally avoids SessionStart hooks for cross-environment stability (Windows + WSL + remote).
- Run `using-superpowers` manually at the start of each new thread.
- If you already keep a mirrored copy under another Copilot plugin directory, recompute `$PluginUri` from that folder instead of editing URI encoding manually.