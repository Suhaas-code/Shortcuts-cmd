# Customization

Run `shortcuts edit` and make it yours. The data file is plain text:

```
// a line starting with // is a comment (never shown)

# Section Name
key<TAB>description
```

For colors, see [colors.md](colors.md). To seed sections automatically instead
of writing them by hand, see [`shortcuts autoadd`](reference.md#shortcuts-autoadd).

## Format

- **`# Section`** — a section header. `##` / `###` render as a lighter
  `--- Section ---` sub-header for a second level of grouping.
- **`key<TAB>description`** — one shortcut. Separate the two with a **Tab**
  (a run of 2+ spaces also works). Columns are aligned automatically on print.
- **`` `key` ``** — wrap individual keys in backticks to highlight them in a
  distinct color, separate from connectors like `+` or `/` left outside the
  backticks.
- **`**bold**`, `*italic*`, `_italic_`** — inline emphasis inside a key or
  description renders with ANSI styling; the markers themselves never print.
- **`---`** (a line of only `---`, `***`, or `___`) — a horizontal rule.
- **`// ansi = off`** — disables **all** color and styling (bold/italic too).
  Handy when raw escape codes leak through, e.g. some SSH or WSL sessions.
  Equivalent to `NO_COLOR`, but it travels inside the file.
- **`// ...`** — a comment. Ignored when printing.
- Blank lines are ignored.
- **`!!!` ... `!!!`** — a plaintext fence. Everything between a line of just
  `!!!` and the next such line prints exactly as written, in the key color,
  with no row-splitting, no `` `key` `` highlighting, and no `**bold**` /
  `*italic*` parsing. Use it for pasted secrets, prompts, IPs, or any block
  that shouldn't be read as a shortcut.
- **`!text`** — a single plaintext line, shorthand for a one-line `!!!` fence.
  The leading `!` (and one space after it, if present) is stripped; the rest
  prints verbatim in the key color.

Example:

```
# Git
git st      status
git co      checkout

# tmux
`Ctrl+b` `%`    split vertical
`Ctrl+b` `"`    split horizontal

# Notes
!api-key-a1b2c3d4
!!!
Reminder to self: this block is never parsed as shortcuts —
`backticks`, **bold**, and _italic_ all print as literal characters.
!!!
```

## Markdown, adapted for the terminal

The format is a deliberate **subset of Markdown** tuned for a TUI cheat sheet.
What carries over, what changed, and what is intentionally left out:

| Markdown | In `shortcuts` |
|---|---|
| `#` / `##` / `###` headings | Section headers — level 1 → `=== Title ===`, level 2+ → `--- Title ---` |
| `**bold**` | Bold (ANSI) |
| `*italic*` / `_italic_` | Italic (ANSI) |
| `` `code` `` | **Repurposed**: highlights an individual **key**, not literal code |
| `---` / `***` / `___` | Horizontal rule |
| `<TAB>` between two cells | **shortcuts-specific**: splits a line into `key → description`, auto-aligned |
| `// comment` | **shortcuts-specific**: a comment / `// color` directive (not Markdown) |
| ` ``` ` code fence | **Repurposed as `!!!`**: backticks already mean *key highlight* here, so a plaintext fence uses `!!!` instead — see [Format](#format) above |

**Different from standard Markdown, on purpose:**

- Backticks mark a **key**, not inline code — so `` `Ctrl` + `Shift` + `W` ``
  colors each key and leaves the `+` connectors plain.
- Emphasis is only detected **outside** backticks. Keep real `*` / `_` / `+`
  keys wrapped in backticks (`` `*` ``) so they are never mistaken for emphasis.
- A single unmatched `*` or `_` is left as literal text.
- Emphasis renders as ANSI styling, so it disappears cleanly when color is off
  (piped output, `NO_COLOR`, or `// ansi = off`) — only the markers are stripped.

**Deferred for the TUI experience** (written as plain text if you use them):
tables, images, links, blockquotes, ordered/nested and task lists, and raw
HTML. A cheat-sheet row is a `key → description` pair, so those block
elements have no place to render.
