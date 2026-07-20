# Working in this repository

A Typst template that turns Markdown in `content/` into a branded Serokell PDF.
Authors only ever write Markdown; all design lives in `template.typ`.

## Build

```bash
./build.sh example-proposal      # -> out/example-proposal.pdf
./build.sh <name> --watch        # rebuild on save
just build <name>                # same thing, if just is installed
```

`build.sh` is a single `typst compile` call. Fonts come from `assets/fonts` via
`--font-path` with `--ignore-system-fonts`, so nothing depends on the machine.

## Layout

| File | Role |
| --- | --- |
| `template.typ` | All design. Tokens at the top, then artwork, footer, cover, table helpers, and the `report` show rule. |
| `main.typ` | Generic wrapper. Reads the `.md` path from `--input`, parses frontmatter, calls `cmarker.render`. Not edited to write a document. |
| `content/` | Author `.md` files and their images. |
| `assets/` | Bundled fonts, and the two mountain PNGs. |

## Common requests, and where they are changed

Everything below is a token near the top of `template.typ` unless stated.

| Request | Change |
| --- | --- |
| "make tables full width" | `table-width` to `"full"`. Per document instead: `tables: full` in that file's frontmatter. Values are `"auto"` and `"full"`. |
| "change the accent colour" | `accent` |
| "the title is too bold / too big" | `title-weight`, `title-size`. Weights `medium` through `black` are present in `assets/fonts`; anything else needs a new file copied in from Google Fonts. |
| "body text bigger / tighter" | `size-body`, `leading-body` |
| "the mountain is too big / too high up the page" | `art-peak-height` sizes it; `art-fade-start` controls how far down the page it stays fully white. |
| "more / less white space at the bottom" | `page-margin.bottom` |
| "move the page number" | `make-footer`. It is centred on `footer-baseline`, the line the Serokell mark sits on. |
| "different heading style" | The `show heading.where(level: N)` rules inside `report`. |
| "the code block should look different" | The `show raw.where(block: true)` rule inside `report`. |

## Traps, already paid for

These are real bugs that were hit and fixed here. Do not re-derive them.

- **Do not add `set image(width: 100%)`.** A global image set rule also applies
  to the cover and footer artwork and, combined with their explicit `height`,
  blows them up to full width and pushes them off the page. Body images get
  their width in the `cmarker.render` scope in `main.typ` instead.
- **Do not wrap `raw` in `par()` inside its show rule.** `par(..., it)` makes
  Typst treat the code as block content inside a paragraph and silently drop the
  whole block. Use `{ set par(...); it }`.
- **A `show table` rule that returns a new `table` recurses** on its own output.
  That is why `stretch-table` builds a `grid`.
- **Markdown column alignment is on the table element's `align` field**, an
  array like `(left, center, right)`, not on the cells. Any rebuild must copy it
  or every column silently goes left.
- **cmarker's `table` cannot be replaced through its `scope`**, even though the
  source looks like it can. cmarker also resolves `table.cell` and
  `table.header` against that name, and a user-defined function has no fields.
- **The cover sets `background: none`.** Without it the cover inherits the
  veiled content-page backdrop on top of its own artwork.
- **The footer artwork is a page background, not footer content.** It is drawn
  at full size behind the text and whitened by a gradient painted over the
  photo. The photo is never made semi-transparent, or the page shows through the
  rock.

## Verifying a change

Rendering the source is not enough. Several of the bugs above compiled cleanly
and were only visible in the output, so look at the actual PDF:

```bash
./build.sh example-proposal
pdftoppm -png -r 110 out/example-proposal.pdf /tmp/page   # then read /tmp/page-N.png
```

Check the artwork after any layout change, and check a page whose text runs all
the way to the bottom margin, not just the short example pages.

If `assets/footer-mountains-*.png` are missing, `build.sh` warns and the
template falls back to a placeholder rather than failing. That path should keep
working.

## House rules

- Never use en dash or em dash anywhere, including commit messages. Plain `-`.
- Commits carry no co-author trailer.
- README and all repository content are in English.
