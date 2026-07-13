# shortcuts

Your personal keyboard-shortcut cheat sheet, one command away, in every shell.

You're mid-task when your mind blanks on a shortcut. Instead of leaving the
terminal to search the web or dig through notes, **shortcuts** prints it right
there — a clean, aligned, colored cheat sheet, searchable, editable in your own
editor. Keep shortcuts, notes, IPs, or plaintext passwords — anything you want
a glance away in your CLI.

One plain-text data file, one lightweight script per platform. Identical
behavior across PowerShell, cmd, Linux, macOS, WSL, and Git Bash. Fully
offline, zero runtime dependencies, updates only when you ask.

## Install

=== "Windows (PowerShell)"

    ```powershell
    irm https://github.com/Suhaas-code/shortcuts-cmd/releases/latest/download/install.ps1 | iex
    ```

=== "Linux · macOS · WSL · Git Bash"

    ```bash
    curl -fsSL https://github.com/Suhaas-code/shortcuts-cmd/releases/latest/download/install.sh | bash
    ```

The installer puts `shortcuts` on your `PATH` and seeds a default list matched
to your environment. Open a new terminal, or run the one-liner it prints, to
use it in the current shell. Re-running is safe — it never overwrites your
edits. → [Full installation details](installation.md).

## Quick example

```console
$ shortcuts

=== Panes ===
Alt + Shift + +           Split pane
Alt + Shift + -           Split pane horizontally
Alt + Arrow Keys          Move focus between panes
...

$ shortcuts search pane
=== Panes ===
Alt + Shift + +           Split pane
...

$ shortcuts edit
Opening shortcuts in the default editor...
```

## Where to next

<div class="grid cards" markdown>

- **[CLI Reference](reference.md)** — every command, its flags, and what it does
- **[Customization](customization.md)** — the data-file format and Markdown-lite syntax
- **[Colors](colors.md)** — theming and turning color off
- **[Architecture](architecture.md)** — how the two scripts stay in parity

</div>
