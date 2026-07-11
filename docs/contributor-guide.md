# Contributor guide

Thanks for helping out. `shortcuts` is deliberately small and dependency-free —
the bar for a change is that it keeps both scripts identical in behavior and adds
no runtime dependencies.

See [architecture.md](architecture.md) for how the pieces fit together.

## Golden rule: parity

[`src/shortcuts.ps1`](../src/shortcuts.ps1) and
[`src/shortcuts.sh`](../src/shortcuts.sh) must produce **byte-identical**
rendered output for the same data file. Any parsing or rendering change lands in
**both** scripts in the same PR. When in doubt, diff their output.

## Running locally (without installing)

The scripts read their data file from a fixed per-environment path. Point that
path at a scratch file with an environment override, then run the script
directly — no install, no PATH change.

**POSIX shell:**

```bash
export XDG_CONFIG_HOME=/tmp/sc-dev
mkdir -p "$XDG_CONFIG_HOME/shortcuts"
cp src/shortcuts/linux.txt "$XDG_CONFIG_HOME/shortcuts/shortcuts.txt"
bash src/shortcuts.sh            # print
bash src/shortcuts.sh search pane
bash src/shortcuts.sh version
```

**PowerShell:**

```powershell
$env:APPDATA = "$env:TEMP\sc-dev"
New-Item -ItemType Directory -Force "$env:APPDATA\shortcuts" | Out-Null
Copy-Item src\shortcuts\windows.txt "$env:APPDATA\shortcuts\shortcuts.txt"
.\src\shortcuts.ps1
```

Color is disabled automatically when output is piped/redirected, so a captured
run shows plain text (emphasis markers and backticks stripped). To see ANSI, run
in a real terminal.

## Editing the data format

Both parsers walk the file line by line in the same order (blank → comment →
rule → heading → row). If you add a token:

1. implement it in the `awk` block of `render()` in `shortcuts.sh` **and** in
   `Show-Shortcuts` in `shortcuts.ps1`;
2. make sure it is stripped cleanly when color is off;
3. keep column-width math based on **visible** width (ignore markup);
4. never change how `//` comment lines are handled — they must always be
   invisible in output.

## Adding or editing shortcuts

Edit the seed files under [`src/shortcuts/`](../src/shortcuts/):

- `windows.txt` — Windows Terminal
- `linux.txt` — terminal + readline + tmux
- `macos.txt` — macOS Terminal / iTerm2

Keep each key wrapped in `` `backticks` `` and separate key from description with
a real Tab. `src/shortcuts.txt` is the generic fallback — keep it in sync with
`windows.txt` unless there's a reason to diverge.

## Versioning

Bump `VERSION` / `$VERSION` in **both** scripts together (they are read by
`version` and `help`). This project uses simple semver-ish tags: `vMAJOR.MINOR.PATCH`.

## Releasing

Distribution is GitHub Releases with **flattened** asset names (see
[architecture.md](architecture.md#distribution)). To cut a release:

```bash
# 1. commit the version bump + changes, push to main
git commit -am "feat: … (vX.Y.Z)"
git push origin main

# 2. stage flattened assets in a temp dir
REL="$(mktemp -d)"
cp install.ps1 install.sh \
   src/shortcuts.ps1 src/shortcuts.sh src/shortcuts.txt \
   src/shortcuts/windows.txt src/shortcuts/linux.txt src/shortcuts/macos.txt "$REL"/

# 3. create the release (marks it 'latest')
gh release create vX.Y.Z "$REL"/* --title "vX.Y.Z — …" --notes "…"
```

The install one-liners and `shortcuts update` always target `releases/latest`,
so a new release reaches everyone as soon as it is published.

## Checklist before opening a PR

- [ ] Change is in **both** scripts, output diffed and identical.
- [ ] No new runtime dependency.
- [ ] `// comment` lines still never render.
- [ ] Color-off output is clean plain text.
- [ ] `VERSION` bumped in both scripts (if user-visible behavior changed).
- [ ] Docs updated if the format, commands, or install flow changed.
