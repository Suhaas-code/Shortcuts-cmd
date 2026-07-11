# Installation

`shortcuts` installs from a single one-liner. No runtime, no dependencies — just
one script per platform, fetched from GitHub Releases.

## Install

**Windows** (PowerShell):

```powershell
irm https://github.com/Suhaas-code/shortcuts-cmd/releases/latest/download/install.ps1 | iex
```

**Linux · macOS · WSL · Git Bash**:

```bash
curl -fsSL https://github.com/Suhaas-code/shortcuts-cmd/releases/latest/download/install.sh | bash
```

The installer:

1. drops the script somewhere on your `PATH`,
2. seeds a default shortcut list **matched to your environment** — Windows
   Terminal keys on Windows, terminal + readline + tmux keys on Linux, and
   macOS Terminal / iTerm2 keys on macOS,
3. adds its directory to your `PATH` if it isn't already there.

Open a **new** terminal afterwards — or run the one-line command the installer
prints to enable `shortcuts` in your **current** shell without restarting.

> **Re-running an installer is safe.** It upgrades the script but **never
> overwrites your edited shortcuts.** To pull the newest script later without
> re-running the installer, use `shortcuts update`.

## Where things live

| | Unix (Linux/macOS/WSL/Git Bash) | Windows (PowerShell/cmd) |
|---|---|---|
| Data file | `~/.config/shortcuts/shortcuts.txt` | `%APPDATA%\shortcuts\shortcuts.txt` |
| Script | `~/.local/bin/shortcuts` | `%LOCALAPPDATA%\Programs\shortcuts\` |

`shortcuts path` always prints the data file the current environment uses.

> **Note:** On Windows, a native PowerShell/cmd install and a Git Bash/WSL
> install keep **separate** data files — each environment is self-contained.

## Uninstalling

`shortcuts uninstall` removes **everything** it installed and nothing else — the
script, your `shortcuts` config directory, and the single PATH line/entry the
installer added. It never deletes shared directories like `~/.local/bin`. Add
`-y` to skip the confirmation prompt.

You can also uninstall straight from the installers, handy if the command isn't
on your `PATH`:

```powershell
# Windows
& ([scriptblock]::Create((irm https://github.com/Suhaas-code/shortcuts-cmd/releases/latest/download/install.ps1))) -Uninstall
```

```bash
# Linux · macOS · WSL · Git Bash
curl -fsSL https://github.com/Suhaas-code/shortcuts-cmd/releases/latest/download/install.sh | bash -s -- --uninstall
```
