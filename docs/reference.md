# CLI Reference

Every `shortcuts` command, its flags, and exact behavior. Both
[`shortcuts.ps1`](https://github.com/Suhaas-code/shortcuts-cmd/blob/main/src/shortcuts.ps1)
and
[`shortcuts.sh`](https://github.com/Suhaas-code/shortcuts-cmd/blob/main/src/shortcuts.sh)
implement identical commands and produce byte-identical output — see
[Architecture](architecture.md) for how parity is kept.

| Command | Summary |
|---|---|
| [`shortcuts`](#shortcuts) | Print your shortcuts |
| [`<page>`](#shortcuts-page) | Print a named page |
| [`new <name>`](#shortcuts-new-name) | Create a new page |
| [`rm <name> [-y]`](#shortcuts-rm-name) | Delete a page |
| [`pages`](#shortcuts-pages) | List pages |
| [`search <term>`](#shortcuts-search-term) | Filter by keyword or section heading |
| [`autoadd [-y]`](#shortcuts-autoadd) | Add starter shortcuts for detected CLI tools |
| [`edit`](#shortcuts-edit) | Open your shortcuts in your editor |
| [`path`](#shortcuts-path) | Print the path of every shortcut file, by name |
| [`reset [-y]`](#shortcuts-reset) | Restore the default shortcuts |
| [`update`](#shortcuts-update) | Update the `shortcuts` script itself |
| [`version`](#shortcuts-version) | Neofetch-style banner: version, environment, counts |
| [`uninstall [-y]`](#shortcuts-uninstall) | Remove shortcuts completely |
| [`help`](#shortcuts-help) | Show usage |

A command that needs the data file (`shortcuts`, `search`, `edit`, `autoadd`)
downloads the environment-matched default automatically on first run if none
exists yet — [`reset`](#shortcuts-reset) re-downloads it *every* time it runs,
by design. `path`, `version`, `update`, `uninstall`, and `help` never trigger
that download. Named pages (`<page>`, `new`, `rm`, `edit <page>`, `pages`)
never trigger it either — there's no remote seed for a page, so a missing or
invalid page name is always an error, not a download.

Any unrecognized command prints usage and exits `1` — to stderr on
`shortcuts.sh`; `shortcuts.ps1` writes it via `Write-Host`, which lands on the
host/information stream rather than stderr, so redirecting `2>` won't catch it
on Windows. This is the one output divergence between the two scripts.

Every error (bad page name, missing argument, download failure, ...) is
printed as `shortcuts: <message>` with the `shortcuts:` tag colored bold red —
one consistent error marker across the whole CLI, in the same style as
`git`/`cargo`. Respects `NO_COLOR` and falls back to plain text on a
non-terminal, same as the rest of the color system (see
[Customization](customization.md)).

---

## `shortcuts`

```console
shortcuts
shortcuts list
```

Prints every section and shortcut in your data file, aligned and colored, in
file order. `list` is an explicit alias for the no-argument form.

```console
$ shortcuts

=== Panes ===
Alt + Shift + +           Split pane
Alt + Shift + -           Split pane horizontally
...
```

---

## `shortcuts <page>`

```console
shortcuts <name>
```

Prints a named page — a second (or third, ...) shortcut sheet alongside your
default one, stored as its own file. Only reachable by bare name if `<name>`
isn't one of the reserved command words below and a page by that name
already exists (see [`new`](#shortcuts-new-name)); otherwise this is the
"unrecognized command" path.

Page names are restricted to `A-Z`, `a-z`, `0-9`, `-`, and `_`, and can't
start with `-` — enforced everywhere a page name is accepted (`<page>`,
`new`, `rm`, `edit <page>`), so a name can never resolve outside the config
directory.

Reserved words (can't be used as a page name): `list`, `edit`, `search`,
`find`, `autoadd`, `path`, `where`, `reset`, `update`, `upgrade`, `version`,
`uninstall`, `remove`, `help`, `new`, `rm`, `pages`, `default`.

---

## `shortcuts new <name>`

```console
shortcuts new <name>
```

Creates a new page: `shortcuts-<name>.txt` in the config directory, seeded
with a single `# <name>` heading. Errors if `<name>` is missing, reserved, or
already exists (existing pages are edited, not re-created — see
[`edit`](#shortcuts-edit)).

```console
$ shortcuts new alpha
Created page "alpha" at ~/.config/shortcuts/shortcuts-alpha.txt
Edit it: shortcuts edit alpha
```

---

## `shortcuts rm <name>`

```console
shortcuts rm <name> [-y|--yes]
```

Deletes a page. Prompts `Delete page "<name>" (<path>)? [y/N]` unless
`-y`/`--yes` is given. Errors if `<name>` is missing, reserved, or no such
page exists. The default sheet (`shortcuts.txt`) isn't deletable this way —
see [`uninstall`](#shortcuts-uninstall) or [`reset`](#shortcuts-reset).

| Flag | Effect |
|---|---|
| `-y`, `--yes` | Skip the confirmation prompt |

---

## `shortcuts pages`

```console
shortcuts pages
```

Lists every page: `default` (if the data file exists) followed by each
`shortcuts-<name>.txt` found in the config directory, one name per line. If
none exist yet, prints a hint to create one.

---

## `shortcuts search <term>`

```console
shortcuts search <term>
shortcuts find <term>      # alias
```

Filters output by `<term>` (case-insensitive). Two match modes:

- **Term matches a section heading** — every row in that section is printed,
  in full.
- **Otherwise** — only rows whose key or description contains `<term>` are
  printed, across all sections. Plaintext lines (see
  [Customization → `!!!` / `!`](customization.md#format)) match on their
  literal text the same way.

Horizontal-rule rows (`---`) are dropped from filtered output either way.
Omitting `<term>` is a usage error (`usage: shortcuts search <term>`, exit `1`).

```console
$ shortcuts search pane
=== Panes ===
Alt + Shift + +           Split pane
Alt + Shift + -           Split pane horizontally
...
```

---

## `shortcuts autoadd`

```console
shortcuts autoadd [-y|--yes]
```

Scans `PATH` for a fixed list of popular CLI tools and appends a starter
shortcut section for each one it finds — skipping any tool whose section
heading already exists in your data file (case-insensitive match). Previews
what it will add and what's already present, then prompts for confirmation
unless `-y`/`--yes` is given. If nothing new is detected, it says so and exits
without prompting.

| Flag | Effect |
|---|---|
| `-y`, `--yes` | Skip the confirmation prompt |

Detected by executable name on `PATH`:

| Tool | Exe | Starter shortcuts added |
|---|---|---|
| Claude Code | `claude` | `/model`, `/clear`, `/diff`, `Ctrl+C` (cancel), `Esc` (cancel input), `Ctrl+J` (newline), `Ctrl+D` (exit) |
| Codex | `codex` | `/model`, `/approvals`, `/init`, `/new`, `/diff`, `Esc` (interrupt), `Ctrl+C` twice (quit) |
| opencode | `opencode` | `/init`, `/new`, `/models`, `/sessions`, `/share`, `/undo`, `Esc` (interrupt), `Ctrl+C` (exit) |
| Aider | `aider` | `/add`, `/drop`, `/ask`, `/architect`, `/diff`, `/undo`, `/run`, `/exit` |
| Gemini | `gemini` | `/help`, `/clear`, `/chat`, `/tools`, `/mcp`, `/memory`, `Ctrl+C` twice (cancel/exit) |
| Vim | `vim` | `i`, `Esc`, `:w`, `:q`, `:wq`, `dd`, `/` |
| Neovim | `nvim` | `i`, `Esc`, `:w`, `:q`, `:wq`, `gg`, `G` |
| Git | `git` | `git status`, `git add`, `git commit`, `git push`, `git pull`, `git log` |
| tmux | `tmux` | `Ctrl+b c`, `Ctrl+b n`, `Ctrl+b %`, `Ctrl+b "`, `Ctrl+b d`, `Ctrl+b x` |
| fzf | `fzf` | `Ctrl+R`, `Ctrl+T`, `Alt+C`, `Tab`, `Enter` |
| Docker | `docker` | `docker ps`, `docker images`, `docker build`, `docker run`, `docker exec`, `docker logs` |
| kubectl | `kubectl` | `kubectl get`, `kubectl describe`, `kubectl logs`, `kubectl apply`, `kubectl exec`, `kubectl delete` |
| ripgrep | `rg` | `rg pattern`, `rg -i`, `rg -n`, `rg -w`, `rg -l`, `rg -t py`, `rg -A 3 -B 3` |
| jq | `jq` | `` jq '.' ``, `` jq '.field' ``, `` jq '.[]' ``, `jq -r`, `jq -c`, `jq -s`, `` jq 'select(...)' `` |
| GitHub CLI | `gh` | `gh pr create`, `gh pr list`, `gh pr checkout`, `gh pr view --web`, `gh issue create`, `gh repo clone`, `gh repo create` |
| Terraform | `terraform` | `terraform init`, `terraform plan`, `terraform apply`, `terraform destroy`, `terraform fmt`, `terraform validate`, `terraform show` |
| FFmpeg | `ffmpeg` | `ffmpeg -i`, `-c:v libx264`, `-crf 23`, `-vn`, `-an`, `-ss`, `-c copy` |
| uv (Python) | `uv` | `uv init`, `uv add`, `uv remove`, `uv run`, `uv sync`, `uv venv`, `uv python install` |
| Cargo | `cargo` | `cargo new`, `cargo build`, `cargo run`, `cargo test`, `cargo add`, `cargo check`, `cargo clippy` |
| Redis CLI | `redis-cli` | `SET`, `GET`, `DEL`, `KEYS *`, `EXPIRE`, `TTL`, `exit` |
| MongoDB Shell | `mongosh` | `show dbs`, `use <db>`, `show collections`, `db.<coll>.find()`, `db.<coll>.insertOne()`, `db.help()`, `exit` |
| MySQL CLI | `mysql` | `SHOW DATABASES;`, `USE <db>;`, `SHOW TABLES;`, `DESCRIBE <table>;`, `SELECT * FROM <table>;`, `help`, `quit` |
| Tree | `tree` | `tree`, `tree -L 2`, `tree -a`, `tree -d`, `tree -f`, `tree --dirsfirst`, `` tree -I 'pattern' `` |
| Rclone | `rclone` | `rclone config`, `rclone lsd`, `rclone ls`, `rclone copy`, `rclone sync`, `rclone move`, `rclone mount` |
| 7-Zip | `7z` | `7z a`, `7z x`, `7z e`, `7z l`, `7z t`, `7z u`, `7z d` |
| yt-dlp | `yt-dlp` | `yt-dlp URL`, `yt-dlp -f`, `yt-dlp -x --audio-format mp3`, `yt-dlp -o`, `yt-dlp -F`, `yt-dlp --write-subs`, `yt-dlp -U` |
| Poetry | `poetry` | `poetry add`, `poetry install`, `poetry update`, `poetry remove`, `poetry show`, `poetry run`, `poetry build` |
| npm | `npm` | `npm install`, `npm install <pkg>`, `npm run <script>`, `npm ci`, `npm update`, `npm uninstall <pkg>`, `npm list` |
| pnpm | `pnpm` | `pnpm install`, `pnpm add <pkg>`, `pnpm run <script>`, `pnpm dlx <pkg>`, `pnpm update`, `pnpm remove <pkg>`, `pnpm list` |
| SQLite3 | `sqlite3` | `sqlite3 <file>`, `.tables`, `.schema <table>`, `.headers on`, `.mode column`, `.dump`, `.quit` |
| AWS CLI | `aws` | `aws configure`, `aws sts get-caller-identity`, `aws s3 ls`, `aws s3 cp`, `aws ec2 describe-instances`, `aws configure list`, `aws help` |
| Google Cloud CLI | `gcloud` | `gcloud init`, `gcloud auth login`, `gcloud config set project <id>`, `gcloud config list`, `gcloud compute instances list`, `gcloud projects list`, `gcloud components update` |

The rows it adds are ordinary data-file lines — [`shortcuts edit`](#shortcuts-edit)
afterward to tailor them. See [Customization](customization.md) for the
data-file format itself.

```console
$ shortcuts autoadd
autoadd — shortcuts for detected CLI tools

Will add sections:
  + Git  (git)
  + tmux  (tmux)

Already present (skipped): Vim

Append 2 section(s) to ~/.config/shortcuts/shortcuts.txt? [y/N]
```

---

## `shortcuts edit`

```console
shortcuts edit
shortcuts edit <page>
```

Opens the data file in your editor — or a named page, if given (errors if
that page doesn't exist yet; see [`new`](#shortcuts-new-name)). This is also
how you update an existing page, since there's no separate `update`-a-page
command. Editor resolution:

- **PowerShell:** `$env:EDITOR`, else `notepad`.
- **POSIX:** `$VISUAL`, then `$EDITOR`, then the first of `nano`, `vim`, `vi`
  found on `PATH`. Errors (`no editor found. Set $EDITOR.`) if none resolve.

---

## `shortcuts path`

```console
shortcuts path
shortcuts where    # alias
```

Prints one `<name>  <path>` line per shortcut file and exits — no other side
effects. `default` is always listed first, even if `shortcuts.txt` doesn't
exist yet; any [pages](#shortcuts-page) found in the config directory follow,
name-column-aligned to the longest name.

```console
$ shortcuts path
default           ~/.config/shortcuts/shortcuts.txt
alpha             ~/.config/shortcuts/shortcuts-alpha.txt
betaverylongname  ~/.config/shortcuts/shortcuts-betaverylongname.txt
```

| Environment | Config directory |
|---|---|
| Unix (Linux/macOS/WSL/Git Bash) | `${XDG_CONFIG_HOME:-~/.config}/shortcuts/` |
| Windows (PowerShell/cmd) | `%APPDATA%\shortcuts\` |

---

## `shortcuts reset`

```console
shortcuts reset [-y|--yes]
```

Overwrites the data file with the environment-matched default, re-downloaded
from the latest GitHub release (see
[environment-matched defaults](architecture.md#environment-matched-defaults)).
Prompts `Overwrite <path> with defaults? [y/N]` unless the file doesn't exist
yet or `-y`/`--yes` is given.

| Flag | Effect |
|---|---|
| `-y`, `--yes` | Skip the confirmation prompt |

---

## `shortcuts update`

```console
shortcuts update
shortcuts upgrade    # alias
```

Re-downloads the `shortcuts` **script itself** (not your data file) from the
latest GitHub release and overwrites it in place. Prints `Updating
shortcuts...`, then a colored `Updated` line — with an old → new version
number if the release changed, or just the path if you're already current.

- **POSIX:** downloads to a temp file, `chmod +x`, then `mv`s it over the
  resolved install path — avoids truncating a script that's currently
  executing.
- **PowerShell:** downloads to a temp file, then copies it over
  `$PSCommandPath` (falls back to the default install location if unset).

```console
$ shortcuts update
Updating shortcuts...
Updated shortcuts (1.6.0 → 1.6.1) at ~/.local/bin/shortcuts
```

---

## `shortcuts version`

```console
shortcuts version
shortcuts -v
shortcuts --version
```

Prints a neofetch-style banner: ASCII logo, `shortcuts` version, shell
environment (e.g. `bash 5.2`, `PowerShell 7.4`), detected OS, shortcut count
(`N in M sections`), editor, data-file path, a live preview of the active
color palette, and the repo link. Shows `0 in 0 sections` if the data file
doesn't exist yet — it does not create one.

The editor line differs slightly by platform: on PowerShell it's the same
value `edit` would actually use (`$env:EDITOR` or `notepad`). On POSIX it
shows `$VISUAL`/`$EDITOR` if set, otherwise the literal placeholder
`nano/vim/vi (auto)` — it doesn't probe `PATH` the way `edit` does.

---

## `shortcuts uninstall`

```console
shortcuts uninstall [-y|--yes]
shortcuts remove [-y|--yes]    # alias
```

Removes everything `shortcuts` installed, and nothing else — the **config
directory** (data file + folder, only if the resolved path ends in
`/shortcuts`, as a safety check against removing the wrong directory), **the
installed script** (the single `shortcuts` file/shim), and **the `PATH`
entry** the installer added. Order differs slightly by platform (end state is
identical):

- **POSIX:** removes the config directory, then the script file, then strips
  the `# Added by shortcuts installer` marker block and its `.local/bin` line
  from `~/.zshrc`, `~/.bashrc`, and `~/.profile`.
- **PowerShell:** removes the program directory from the User `PATH` registry
  value first, then the config directory, then hands off to a detached,
  hidden `cmd.exe` that waits ~3 seconds (so the running script isn't deleted
  out from under itself) before `rmdir /s /q`-ing the program directory.

Prompts `Proceed? [y/N]` unless `-y`/`--yes` is given. Open a new shell
afterward to drop the `PATH` change.

| Flag | Effect |
|---|---|
| `-y`, `--yes` | Skip the confirmation prompt |

You can also trigger uninstall straight from the installer scripts, useful if
`shortcuts` isn't on `PATH` anymore — see [Installation → Uninstalling](installation.md#uninstalling).

---

## `shortcuts help`

```console
shortcuts help
shortcuts -h
shortcuts --help
```

Prints usage for every command plus the resolved data-file path. Also shown
(with exit `1`) when an unrecognized command is given — on `shortcuts.sh` this
goes to stderr; `shortcuts.ps1` writes it via `Write-Host` instead, so it
won't be caught by `2>` redirection on Windows.
