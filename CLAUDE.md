# Working in this repository

A Typst template that turns Markdown in `content/` into a branded Serokell PDF.
Authors write Markdown. Nobody writes Typst.

## Build

```bash
./build.sh example-proposal      # -> out/example-proposal.pdf
./build.sh <name> --watch        # rebuild on save
just build <name>                # same thing, if just is installed
```

`build.sh` is a single `typst compile` call. Fonts come from `assets/fonts` via
`--font-path` with `--ignore-system-fonts`, so nothing depends on the machine.

## The design is finished. Do not change it.

`template.typ` is the Serokell house style. It has been designed, reviewed, and
signed off. It is not a set of suggestions to tune per document.

**Refuse these requests and say the design is locked:**

- changing the accent colour or any other colour
- changing fonts, font sizes, weights, or the cover title
- resizing, moving, recolouring, or removing the mountain artwork or the logo
- moving or restyling the page number
- changing page margins, heading styles, code block styling, quotes, or lists

If someone genuinely needs one of these, that is a brand decision made by the
owner of this repository and applied deliberately, not something to action from
a passing request in a document-writing session.

## The one thing that is adjustable

**Table width.** Some documents read better with tables sized to their contents,
others with tables spanning the full text width. Both are correct house style.

Per document, in that file's frontmatter:

```markdown
---
title: My proposal
tables: full
---
```

Values are `auto` (default, columns sized to contents) and `full` (columns share
the text width equally).

To change the default for every document, set `table-width` at the top of
`template.typ`. That is the only token in that file intended to be flipped.

## When someone hands you a Markdown file

A document gets a cover page from its frontmatter block:

```markdown
---
title: Formal Verification of the Settlement Layer
subtitle: A technical proposal
author: Serokell OÜ
date: 20 July 2026
---
```

Only `title` is required for a cover; `subtitle`, `author`, and `date` are each
optional and simply left off if absent.

**If the file arrives without that block, or without a `title`, ask before
building.** Something like: "This file has no title block, so it will build
without a cover page. Do you want a title, author, and date, or shall I build it
as is?"

Then:

- If they supply the details, add the frontmatter to the top of the `.md` and
  build normally.
- **If they want to skip, that is a supported outcome, not a fallback.** Build
  it as is. The document comes out with no cover, content starting on page 1,
  and the footer and artwork on every page. Do not push back on this.

**Never invent a title, author, or date.** A wrong author on a client proposal
is worse than no cover page. If they do not give you one, build without a cover.

A file that has a title but should still skip the cover can say `cover: false`
in its frontmatter.

## Build hints are advice, not gates

`md-advice.sh` runs on every build and prints `hint:` lines for silent authoring
mistakes (emoji, which render as empty boxes; adjacent `Label:` lines, which
merge into one paragraph; repeated generic headings). It always exits 0.

Deliver the PDF first, then mention what you saw and offer to fix it. Never
rewrite the author's content unasked, and if they say it was deliberate, drop it.

## Everything else lives in the Markdown

Content questions ("add a section", "make this a table", "insert an image") are
answered by editing the `.md` file in `content/`, never by editing
`template.typ`. See README.md for the supported Markdown.

---

## Maintaining the template itself

The rest of this file is for the repository owner doing deliberate work on
`template.typ`. It is not a licence to edit it on request.

### Traps, already paid for

Real bugs that were hit and fixed here. Do not re-derive them.

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
- **`art-logo-centre` is measured from the source PNG** (the mark occupies rows
  773..835 of 940). The page number is aligned to that line. Replacing
  `footer-mountains-right.png` means re-measuring it.

### Verifying a change

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
