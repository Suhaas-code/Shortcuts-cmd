# Colors

Colors are configured with `// color` lines in the data file itself — so your
theme travels with your shortcuts:

```
// color header = bold cyan
// color key    = green
// color desc   = default
// color code   = bold yellow
```

- **Targets:** `header`, `key`, `desc`, and `code` (text inside `` `backticks` ``).
- **Colors:** `black red green yellow blue magenta cyan white gray`, plus
  `bright-*` variants (e.g. `bright-magenta`).
- **Styles:** `bold dim italic underline`. Combine with spaces (`bold bright-cyan`).
- Use `default` for your terminal's normal color.
- The seed files ship with sensible defaults already set, ready to tweak.

## Turning color off

There are three ways to render with no color or styling at all:

- **`NO_COLOR=1`** in the environment — the [standard](https://no-color.org/)
  opt-out, applies to a single run or your whole shell.
- **`// ansi = off`** inside the data file — travels with the file, useful when
  raw escape codes leak through (some SSH or WSL sessions). See
  [customization.md](customization.md).
- **Piped / redirected output** — color turns off automatically when stdout is
  not a terminal, so `shortcuts | grep …` stays clean.

When color is off, emphasis markers (`**`, `*`, `_`) and backticks are still
stripped — you get clean plain text, never raw markup.
