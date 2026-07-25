# Serokell document template

Turn a plain Markdown file into a branded Serokell PDF: documents, candidate
profiles, and 16:9 slide decks.

You write Markdown. You do not write, read, or edit any Typst.

---

## Quick start

```bash
# 1. Install Typst
brew install typst          # macOS
#   other platforms: https://github.com/typst/typst#installation

# 2. Clone and build the example
git clone https://github.com/alexander-rukin/serokell-doc-template
cd serokell-doc-template
./build.sh example-proposal
```

That writes `out/example-proposal.pdf`. If it works, you are set up.

The **first** build downloads the pinned `cmarker` package
(`@preview/cmarker:0.1.8`, ~136 KB) from the Typst package registry, so it
needs network access once. Every build after that is fully offline - fonts and
artwork are committed to the repo, and nothing is read from your system font
directory.

If you use Claude Code, you do not have to clone anything - see
[the Claude Code plugin](#the-claude-code-plugin).

---

## The Claude Code plugin

The same repository is packaged as a Claude Code plugin. With it installed you
do not clone or build by hand - you ask for the PDF.

### Installing

```
/plugin marketplace add alexander-rukin/serokell-doc-template
/plugin install serokell-docs@serokell-docs
```

Or do all of that with one command, which also installs Typst if it is missing
and turns on automatic updates:

```bash
curl -fsSL https://raw.githubusercontent.com/alexander-rukin/serokell-doc-template/main/install.sh | bash
```

Two things worth knowing about what that script does:

- **Typst.** It installs with Homebrew when Homebrew is already there, and
  otherwise downloads the official static binary into `~/.local/bin`. It never
  installs Homebrew itself and never asks for sudo. Pass `SKIP_TYPST=1` to
  handle Typst yourself.
- **`~/.claude/settings.json`.** The CLI has no flag for automatic updates, so
  the script writes `autoUpdate` into your settings file. It copies the file to
  `settings.json.bak` first (once - a later run will not overwrite that
  original), adds one key, and rewrites the file as standard two-space JSON, so
  your own formatting is reflowed even though your settings are kept. It is
  safe to run again. Without automatic updates nothing checks for a newer
  version and you stay on whatever you installed.

### Using it

Ask from any folder on your machine; the file does not have to live in this
repository:

> Make a PDF from proposal.md

> Turn these notes into a candidate profile: notes.txt

> Make a deck about our smart-contract audit process, for a client

Three skills ship with the plugin: `serokell-pdf` (documents), `serokell-cv`
(candidate profiles), and `serokell-slides` (decks). Each knows where the
template is, asks instead of inventing when a title, name, or date is missing,
and writes the PDF next to the source file. Typst still has to be installed.

### Updating

If you did not turn on automatic updates:

```bash
claude plugin marketplace update serokell-docs
```

If the version in `claude plugin list` does not move, reinstall: the
marketplace manifest refreshes, but the cached plugin files do not always
follow.

```bash
claude plugin uninstall serokell-docs@serokell-docs && claude plugin install serokell-docs@serokell-docs
```

---

## Writing a document

Drop a `.md` file into `content/` and build it by name:

```bash
./build.sh my-proposal          # content/my-proposal.md -> out/my-proposal.pdf
./build.sh my-proposal --watch  # rebuild on every save
```

If you have [`just`](https://github.com/casey/just) installed, it wraps the
same script:

```bash
just build example-proposal
just watch example-proposal   # live rebuild while you edit
just all                      # build everything in content/
just list                     # what can I build?
```

A document that lives somewhere else on disk builds with `./render.sh` instead
(see [Scripting the build](#scripting-the-build)).

Start the file with a frontmatter block. This is the only non-Markdown part,
and it is what fills in the cover page:

```markdown
---
title: Formal Verification of the Settlement Layer
subtitle: A technical proposal for hardening on-chain value transfer
author: Serokell OÜ
date: 20 July 2026
---

# First heading

Your content starts here.
```

Only `title` is required. `subtitle`, `author`, and `date` are each optional
and are simply omitted from the cover if absent.

**The frontmatter itself is optional too.** A file with no title block builds
without a cover page: the content starts on page 1 and every page carries the
footer and artwork as usual. Useful for a short note or a draft that does not
warrant a title page. A file that has a title but should still skip the cover
can say `cover: false`.

### Build hints

Every build runs a few advisory checks on your Markdown and prints `hint:`
lines for things that are easy to get wrong and hard to spot afterwards:
adjacent `Label: value` lines (which Markdown merges into one paragraph) and
repeated generic headings. They are suggestions only and never stop the build.

### What's supported

Ordinary Markdown, all of it styled by the template:

| You write | You get |
| --- | --- |
| `# H1` / `## H2` / `### H3` | Branded headings in Google Sans Flex |
| `**bold**`, `*italic*` | Standard emphasis |
| `- item` / `1. item` | Lists with accent-coloured markers |
| `> quote` | Quote block with an accent spine |
| `` `code` `` | Inline code, tinted |
| ```` ```haskell ... ``` ```` | Syntax-highlighted code panel, JetBrains Mono |
| pipe tables | Clean table, hairline rules, no boxes ([see below](#tables)) |
| `![alt](diagram.svg)` | Full-width image |
| `[text](url)` | Accent-coloured link |

### Emoji

Emoji work and render in **colour**, because Noto Color Emoji is bundled as a
fallback. The COLRv1 (vector) build is used, so they stay sharp at any size in
print. Apple Color Emoji is not bundled: its licence does not allow
redistribution.

```markdown
🎓 **Education:** PhD in Computer Science
```

### Tables

Standard Markdown pipe tables. The second row, the one made of dashes, is not
decoration - it is what tells the parser this is a table at all, and it must
have one entry per column:

```markdown
| Phase         | Duration | Effort  |
| ---           | ---      | ---     |
| Specification | 4 weeks  | 1.5 FTE |
| Verification  | 6 weeks  | 2.0 FTE |
```

The first row is the header. It is set in the heading font with a rule under
it; the remaining rows are separated by hairlines. There are no vertical rules
and no outer box.

You do not need to line the pipes up. This is the same table:

```markdown
| Phase | Duration | Effort |
| --- | --- | --- |
| Specification | 4 weeks | 1.5 FTE |
```

**Column alignment** is set with colons in the dash row: `:---` left (the
default), `:---:` centred, `---:` right. Right-aligning numeric columns is
usually worth it:

```markdown
| Item      | Qty | Amount |
| :---      | :---: | ---: |
| Licences  |  12 | 4,800  |
| Support   |   1 | 12,000 |
```

**Inside a cell** you can use `**bold**`, `*italic*`, `` `code` ``, and
`[links](https://example.com)`. All of them are styled as they are in body
text.

One limit worth knowing: a cell cannot contain a real bulleted list or a code
block. You can force a line break inside a cell with `<br>`, but a `-` typed
after it stays a literal dash rather than becoming a bullet.

#### Table width

There are two modes, and which one looks better depends on your document, so
try both:

| Mode | Result |
| --- | --- |
| `auto` (default) | Columns are sized to their contents. A table with little in it stays narrow and sits to the left. |
| `full` | Columns share the text width equally, so every table spans the full measure. Long cells wrap onto several lines. |

Switch per document from the frontmatter:

```markdown
---
title: My proposal
tables: full
---
```

To change the default for every document instead, set `table-width` at the top
of `src/template.typ`. Column alignment from the colons works the same in both
modes.

### Images

Image paths are resolved **relative to your `.md` file**, so if your document
is `content/my-proposal.md`, then `![](diagram.svg)` points at
`content/diagram.svg`. Both raster and SVG work; prefer SVG for anything
vector-shaped, since it stays sharp in print.

See `content/example-proposal.md` for a worked example of every feature above,
and `content/example-profile.md` for the candidate-profile shape.

---

## Slide decks

The same repository also builds branded 16:9 slide decks. A deck is one
markdown file: a layout tag plus text per slide.

The intended way to make one is to ask Claude Code, with the plugin installed:

> Make a deck about our smart-contract audit process, about 15 minutes, for a
> client. Here are my notes: ...

Claude splits the material into slides, picks a layout for each one (there are
37 of them - lists, cards, numbers, timelines, diagrams, device mockups),
writes the `deck.md` next to your notes, renders the PDF and shows it to you.
After that you edit in words - "slide 3 as two columns", "drop slide 6" - and
it rebuilds in seconds. You never pick layouts by hand and never open Typst.

To build a deck file directly:

```bash
./render-deck.sh ~/talks/kickoff.md              # -> ~/talks/kickoff.pdf
THEME=dark ./render-deck.sh ~/talks/kickoff.md   # dark palette
```

Like `render.sh`, it takes a file from anywhere and never writes inside the
template directory. The builder warns when a slide has more text than its
layout holds (overflowing text is clipped, not reflowed) and when the page
count stops matching the slide count. From a checkout, `./build-deck.sh
decks/my-deck.md` does the same build inside the repo; it exists for working on
the template itself.

- `docs/FORMAT.md` - the deck.md reference: every layout, its fields, its
  items.
- `decks/all-layouts.md` - a deck that renders every layout; build it to see
  the vocabulary.
- `src/slides.typ` - the layout library and the locked brand shell.

---

## Scripting the build

`render.sh` and `render-deck.sh` are the entry points the plugin skills call,
and they work the same from your own automation. Both take a file from
anywhere on disk, write the PDF next to it (or to the path you give), and
never write inside the template directory - which matters when the template is
installed read-only as a plugin:

```bash
./render.sh ~/notes/proposal.md            # -> ~/notes/proposal.pdf
./render.sh ~/notes/proposal.md /tmp/x.pdf
```

Underneath, `build.sh` is a thin, dependency-free wrapper around one
`typst compile` call, so it is safe to shell out to from a service:

```bash
typst compile src/main.typ out/doc.pdf \
  --root . \
  --font-path assets/fonts \
  --ignore-system-fonts \
  --input doc=content/doc.md \
  --input art=true
```

Every path is relative to the repo root and the template takes no ambient
state, which is what the planned sandboxed Node/TS rendering service will need.

---

## Changing the branding

Document branding lives in `src/template.typ`, at the top of the file:

```typst
#let accent = rgb("#D92B04")
#let ink = rgb("#1A1A1A") // body text
#let font-emoji = "Noto Color Emoji"
#let font-display = ("Google Sans Flex 120pt", font-emoji) // cover title only
#let font-heading = ("Google Sans Flex 36pt", font-emoji) // h1-h3
#let font-body = ("Google Sans Flex 24pt", font-emoji) // body copy
#let page-margin = (top: 24mm, bottom: 40mm, x: 20mm)
```

The slide decks keep their own tokens at the top of `src/slides.typ`.

Google Sans Flex is shipped as one font family per optical size, so the family
name picks the optical size and `weight` picks the cut. Because the repo
bundles static instances rather than the variable font, weights select
reliably and no `fonttools` step is needed.

Only the font cuts actually used are committed. To add a weight or optical
size, copy the matching file from the Google Fonts download into
`assets/fonts/` and reference the family by name.

---

## Repo layout

What you type lives at the root; everything it drives lives in a folder.

```
build.sh          build a document from content/ into out/
build-deck.sh     build a deck from a checkout
render.sh         build a document living anywhere on disk
render-deck.sh    build a deck living anywhere on disk
install.sh        install this as a Claude Code plugin
justfile          convenience wrapper over build.sh

src/template.typ  all branding: tokens, cover, footer, heading/table/code styles
src/main.typ      generic wrapper; driven by --input, never edit to write a doc
src/slides.typ    the slide layout library
src/slidegen.py   deck.md -> Typst
src/md-advice.sh  advisory hints on the author's Markdown

skills/           the Claude Code skills: serokell-pdf, serokell-cv, serokell-slides
.claude-plugin/   plugin and marketplace manifests
content/          your .md documents (and their images)
decks/            your decks
docs/FORMAT.md    the deck.md field reference
assets/fonts/     bundled fonts + OFL licences
assets/           brand artwork and marks (provenance in assets/CREDITS.md)
dev/              test suite and type specimens
out/              generated PDFs (gitignored)
```

Typst paths inside `src/` are anchored at the project root (`/assets/...`), so
the same file compiles from a checkout and from the temporary directory that
`render.sh` and `render-deck.sh` build in.

---

## Printing and artwork

- **The footer artwork bleeds to the page edges**, matching the cover. One
  consequence: the Serokell mark baked into the right-hand peak lands about 5mm
  from the trim edge at footer scale, so a printer with a large unprintable
  margin may clip it. It is decorative there - the legible logo is on the
  cover - but if that matters, reduce the right-hand `dx` in `footer-art`, at
  the cost of a visible hard edge where the peak is cropped in the source PNG.
- **The footer artwork is raster.** `footer-mountains-left.png` and
  `footer-mountains-right.png` are roughly 250 dpi at A4 width. Good enough for
  screen and office printing; **TODO: replace with SVG before sending anything
  to a commercial printer.** The template will pick the new files up as-is if
  they keep the same names.
- **Missing artwork does not break the build.** If the two PNGs are absent,
  `build.sh` detects it, warns, and the template falls back to a plain rule and
  a placeholder note instead of failing.
- **Where the logo lives.** In documents the Serokell mark is baked into
  `footer-mountains-right.png`; there is no separate logo asset on the document
  side. The slide decks use the standalone marks
  `assets/serokell-mark-light.svg` and `assets/serokell-mark-dark.svg`.

---

## Licence

The code in this repository - the Typst layout library and templates, the
generators, the shell scripts, and the skills - is licensed under the **Apache
License 2.0**. See [LICENSE](LICENSE) for the full text and [NOTICE](NOTICE)
for what is and is not covered.

Apache 2.0 was chosen over MIT specifically because section 6 states that the
licence grants no trademark rights. This repository ships the Serokell
wordmark in its artwork, and that carve-out should be explicit in the licence
rather than only in a README note.

### The bundled assets are licensed separately

- **Fonts.** Google Sans Flex, Golos Text, JetBrains Mono, and Noto Color
  Emoji are all under the SIL Open Font License 1.1. The full licence text for
  each ships alongside the font files in `assets/fonts/`, which is what the
  OFL requires when redistributing them.
- **Artwork and logo.** The footer artwork (`assets/footer-mountains-*.png`),
  the slide artwork (`assets/brand-*.png`), and the Serokell marks
  (`assets/serokell-mark-*`) are Serokell brand assets; the wordmark is baked
  into the right-hand footer image and ships standalone as the marks. They are
  here so the template builds out of the box; they are not covered by the
  licence that applies to the code. If you are adapting this template for
  another organisation, replace them. Provenance for every asset is recorded
  in `assets/CREDITS.md`.
