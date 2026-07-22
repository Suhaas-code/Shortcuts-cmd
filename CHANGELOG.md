# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0]

### Added
- `autoadd` now detects 20 more CLI tools: ripgrep (`rg`), `jq`, GitHub CLI
  (`gh`), Terraform, FFmpeg, `uv`, Cargo, Redis CLI, MongoDB Shell
  (`mongosh`), MySQL CLI, `tree`, Rclone, 7-Zip (`7z`), `yt-dlp`, Poetry,
  `npm`, `pnpm`, SQLite3, AWS CLI, and Google Cloud CLI (`gcloud`).

## [1.7.0]

### Added
- Plaintext blocks: wrap raw content (passwords, IPs, pasted prompts) in
  `!!!` fences, or prefix a single line with `!`, to skip shortcut parsing
  entirely — no row-splitting, no `` `key` `` highlighting, no `**bold**` /
  `*italic*` parsing, printed as-is in the key color. Documented in
  [Customization](docs/customization.md) and demonstrated in every default
  seed file's new `# Notes` section.

## [1.6.1]

### Changed
- All errors now print with a bold-red `shortcuts:` tag — one consistent
  error marker across the whole CLI (matches `git`/`cargo` convention),
  respecting `NO_COLOR`/non-tty like the rest of the color system.
- `update` now prints `Updating shortcuts...` while it fetches, then a
  colored `Updated` line showing the old → new version when it changes.

## [1.6.0]

### Added
- Multiple named shortcut pages: `new <name>` creates one, `<name>` (bare)
  views one, `rm <name> [-y]` deletes one, `pages` lists them. `edit` now
  takes an optional page name.

## [1.5.1]

### Fixed
- Corrected the `autoadd` starter shortcuts for the AI CLIs (Claude Code, Codex,
  opencode, Aider, Gemini) against their official docs. Notably `Ctrl`+`C` is
  interrupt/cancel — not quit — across all of them, plus command-name and
  wording fixes (e.g. opencode `/models` and `/new`, Codex `/approvals`, Aider
  `/ask` / `/architect`, Gemini `Ctrl`+`C` twice to exit).

## [1.5.0]

### Added
- `autoadd` command: detects installed CLI tools (Claude Code, Codex, opencode,
  Aider, Gemini, Vim, Neovim, git, tmux, fzf, Docker, kubectl) and appends a
  starter shortcut section for each. Previews what it will add, prompts for
  confirmation (`-y`/`--yes` to skip), and skips any section already present.
- `search` now also matches section headings — a term that matches a heading
  returns every shortcut in that section.

## [1.4.0]

### Added
- Per-environment default cheat sheets: the installer seeds `windows.txt`,
  `linux.txt`, or `macos.txt` based on the detected OS.
- `// ansi = off` directive to strip all styling (useful over SSH/WSL).

## [1.3.0]

### Added
- Markdown-lite rendering in the TUI: `#`/`##`/`###` headings, `---` horizontal
  rules, `**bold**`, and `*italic*` / `_italic_` emphasis.

## [1.2.0]

### Added
- `uninstall` command/flag that removes the program, config, and PATH entry.
- neofetch-style banner for `shortcuts version`.

### Fixed
- Self-delete error when uninstalling via the Windows shim.

## [1.1.1]

### Changed
- Colors refresh.

## [1.1.0]

### Added
- Key highlighting and configurable colors via `// color <target> = <spec>`.

### Changed
- Reorganized the repository layout.

## [1.0.0]

### Added
- Initial release: offline, dependency-free keyboard-shortcut cheat sheet with
  `list`, `search`, `edit`, `path`, `reset`, `update`, `version`, and `help`.

[Unreleased]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.8.0...HEAD
[1.8.0]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.6.1...v1.7.0
[1.6.1]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.5.1...v1.6.0
[1.5.1]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/Suhaas-code/shortcuts-cmd/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Suhaas-code/shortcuts-cmd/releases/tag/v1.0.0
