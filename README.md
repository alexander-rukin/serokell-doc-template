# Serokell document template

Turn a plain Markdown file into a branded Serokell PDF.

You write Markdown. You do not write, read, or edit any Typst.

---

## Quick start

```bash
# 1. Install Typst
brew install typst          # macOS
#   other platforms: https://github.com/typst/typst#installation

# 2. Clone and build the example
git clone <this-repo> && cd serokell-doc-template
./build.sh example-proposal
```

That writes `out/example-proposal.pdf`. If it works, you are set up.

The **first** build downloads the pinned `cmarker` package (~136 KB) from the
Typst package registry, so it needs network access once. Every build after that
is fully offline - fonts and artwork are committed to the repo, and nothing is
read from your system font directory.

If you have [`just`](https://github.com/casey/just) installed you can use it
instead - it is a thin wrapper over the same script:

```bash
just build example-proposal
just watch example-proposal   # live rebuild while you edit
just all                      # build everything in content/
just list                     # what can I build?
```

Fonts are bundled in `assets/fonts/` and passed to Typst explicitly, so the
build does not depend on what is installed on your machine.

---

## Writing a document

Drop a `.md` file into `content/` and build it by name:

```bash
./build.sh my-proposal        # content/my-proposal.md -> out/my-proposal.pdf
```

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

### What's supported

Ordinary Markdown, all of it styled by the template:

| You write | You get |
| --- | --- |
| `# H1` / `## H2` / `### H3` | Branded headings in Google Sans Flex |
| `**bold**`, `*italic*` | Standard emphasis |
| `- item` / `1. item` | Lists with accent-coloured markers |
| `> quote` | Quote block with an accent spine |
| `` `code` `` | Inline code, tinted |
| ```` ```haskell ```` | Syntax-highlighted code panel, JetBrains Mono |
| `\| a \| b \|` | Clean table, hairline rules, no boxes |
| `![alt](diagram.svg)` | Full-width image |
| `[text](url)` | Accent-coloured link |

Image paths are resolved **relative to your `.md` file**, so if your document is
`content/my-proposal.md`, then `![](diagram.svg)` points at
`content/diagram.svg`. Both raster and SVG work; prefer SVG for anything
vector-shaped, since it stays sharp in print.

See `content/example-proposal.md` for a worked example of every feature above.

---

## Changing the branding

All of it lives in `template.typ`, at the top of the file:

```typst
#let accent = rgb("#D92B04")     // Serokell red
#let ink    = rgb("#1A1A1A")     // body text
#let font-body    = "Google Sans Flex 24pt"
#let font-heading = "Google Sans Flex 36pt"
#let font-display = "Google Sans Flex 120pt"
#let page-margin  = (top: 24mm, bottom: 44mm, x: 20mm)
```

Google Sans Flex is shipped as one font family per optical size, so the family
name picks the optical size and `weight` picks the cut. Because the repo bundles
static instances rather than the variable font, weights select reliably and no
`fonttools` step is needed.

To add a weight or optical size, copy the matching file from the Google Fonts
download into `assets/fonts/` and reference the family by name.

---

## Repo layout

```
template.typ    all branding: tokens, cover, footer, heading/table/code styles
main.typ        generic wrapper; driven by --input, never edit to write a doc
build.sh        the build command
justfile        convenience wrapper over build.sh
content/        your .md documents (and their images)
assets/fonts/   bundled fonts + OFL licences
assets/         footer-mountains-{left,right}.png
out/            generated PDFs (gitignored)
```

---

## Notes and TODOs

- **The footer artwork bleeds to the page edges**, matching the cover. One
  consequence: the Serokell mark baked into the right-hand peak lands about 5mm
  from the trim edge at footer scale, so a printer with a large unprintable
  margin may clip it. It is decorative there - the legible logo is on the cover -
  but if that matters, reduce the right-hand `dx` in `footer-art`, at the cost of
  a visible hard edge where the peak is cropped in the source PNG.
- **The footer artwork is raster.** `footer-mountains-left.png` and
  `footer-mountains-right.png` are roughly 250 dpi at A4 width. Good enough for
  screen and office printing; **TODO: replace with SVG before sending anything
  to a commercial printer.** The template will pick the new files up as-is if
  they keep the same names.
- **Missing artwork does not break the build.** If the two PNGs are absent,
  `build.sh` detects it, warns, and the template falls back to a plain rule and
  a placeholder note instead of failing.
- The Serokell logo is baked into `footer-mountains-right.png`; there is no
  separate logo asset to maintain.
- Typst and the `cmarker` package version are pinned (`@preview/cmarker:0.1.8`)
  so builds are reproducible.
- Only the font cuts actually used are committed. To add a weight or optical
  size, download the family from Google Fonts and copy the file you need into
  `assets/fonts/`.

---

## Licence

The code in this repository (`template.typ`, `main.typ`, `build.sh`, the
`justfile`, and the example content) is licensed under the **Apache License
2.0**. See [LICENSE](LICENSE) for the full text.

Apache 2.0 was chosen over MIT specifically because section 6 states that the
licence grants no trademark rights. This repository ships the Serokell wordmark
inside one of the images, and that carve-out should be explicit in the licence
rather than only in a README note.

### The bundled assets are licensed separately

- **Fonts.** Google Sans Flex and JetBrains Mono are both under the SIL Open
  Font License 1.1. The full licence text for each ships alongside the font
  files in `assets/fonts/`, which is what the OFL requires when redistributing
  them.
- **Artwork and logo.** `assets/footer-mountains-*.png` are Serokell brand
  assets, and the right-hand image has the Serokell wordmark baked into it.
  They are here so the template builds out of the box; they are not covered by
  whatever licence applies to the code in this repository. If you are adapting
  this template for another organisation, replace both images.

---

### Scripting the build

`build.sh` is a thin, dependency-free wrapper around one `typst compile` call,
so it is safe to shell out to from a service:

```bash
typst compile main.typ out/doc.pdf \
  --root . \
  --font-path assets/fonts \
  --ignore-system-fonts \
  --input doc=content/doc.md \
  --input art=true
```

Every path is relative to the repo root and the template takes no ambient state,
which is what the planned sandboxed Node/TS rendering service will need.
