# shortcuts

A tiny, customizable terminal command that prints your personal list of keyboard
shortcuts — and lets you edit it in your own editor. Works on Windows, Linux,
macOS, WSL, and Git Bash with zero runtime dependencies.

```
> shortcuts

=== Panes ===
Alt + Shift + +           Split pane
Alt + Shift + -           Split pane horizontally
Alt + Arrow Keys          Move focus between panes
...

> shortcuts edit
Opening shortcuts in the default editor...
```

## Install

**Windows (PowerShell):**

```powershell
irm https://github.com/Suhaas-code/Shortcuts-cmd/releases/latest/download/install.ps1 | iex
```

**Linux / macOS / WSL / Git Bash:**

```bash
curl -fsSL https://github.com/Suhaas-code/Shortcuts-cmd/releases/latest/download/install.sh | bash
```

Restart your terminal afterwards so the new `shortcuts` command is on your `PATH`.

## Usage

| Command | What it does |
|---|---|
| `shortcuts` | Print your shortcuts |
| `shortcuts search <term>` | Filter shortcuts by keyword |
| `shortcuts edit` | Open your shortcuts in your editor |
| `shortcuts path` | Print the data file path |
| `shortcuts reset [-y]` | Restore the default shortcuts |
| `shortcuts update` | Update the `shortcuts` script itself |
| `shortcuts version` | Print the version |
| `shortcuts help` | Show help |

## Customizing

Run `shortcuts edit` and add your own shortcuts. The format is plain text:

```
# Section Name
key<TAB>description
```

- Lines starting with `#` are **section headers**.
- Each shortcut is a `key` and a `description` separated by a **Tab**
  (a run of 2+ spaces also works). Columns are aligned automatically when printed.
- Blank lines are ignored.

Example:

```
# Git
git st      status
git co      checkout

# tmux
Ctrl+b %    split vertical
Ctrl+b "    split horizontal
```

The editor is `$EDITOR` / `$VISUAL` on Unix (falling back to `nano`/`vim`/`vi`),
or `%EDITOR%` on Windows (falling back to Notepad).

## Where things live

| | Unix (Linux/macOS/WSL/Git Bash) | Windows (PowerShell/cmd) |
|---|---|---|
| Data file | `~/.config/shortcuts/shortcuts.txt` | `%APPDATA%\shortcuts\shortcuts.txt` |
| Script | `~/.local/bin/shortcuts` | `%LOCALAPPDATA%\Programs\shortcuts\` |

> **Note:** On Windows, the native PowerShell/cmd install and a Git Bash/WSL
> install keep **separate** data files. Each environment is self-contained.
> Set `NO_COLOR=1` to disable colored output.

## License

MIT — see [LICENSE](LICENSE).
