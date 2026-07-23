---
name: serokell-pdf
description: Turn a Markdown file into a branded Serokell PDF - proposals, reports, technical notes, client documents. Use whenever someone asks to make a PDF from Markdown, build or render a document, produce a proposal or report as PDF, or apply Serokell branding or the house template to a document. Handles the cover page, fonts, and artwork; the author only writes Markdown.
---

# Serokell PDF

Renders a Markdown file into a branded PDF using the Serokell house template.
Fonts and artwork are bundled, so the output is identical on every machine.

## Building

One command. It takes any `.md` anywhere on disk and writes the PDF next to it:

```bash
"${CLAUDE_PLUGIN_ROOT}/render.sh" path/to/document.md
```

To choose the output path:

```bash
"${CLAUDE_PLUGIN_ROOT}/render.sh" path/to/document.md path/to/output.pdf
```

The script prints the path it wrote. Images referenced from the Markdown are
picked up automatically, including ones in subfolders, as long as the paths are
relative to the document.

## Requirement

Typst must be installed. If `render.sh` reports it is missing, tell the user:

```bash
brew install typst          # macOS
```

Other platforms: https://github.com/typst/typst#installation. Do not try to work
around a missing Typst by rendering the document some other way; the output
would not be branded.

## The cover page comes from frontmatter

```markdown
---
title: Formal Verification of the Settlement Layer
subtitle: A technical proposal
author: Serokell OÜ
date: 20 July 2026
---
```

Only `title` is required; `subtitle`, `author`, and `date` are optional and are
left off the cover if absent.

**If the file has no frontmatter, or no `title`, ask before building.** For
example: "This file has no title block, so it will build without a cover page.
Do you want a title, author, and date, or shall I build it as is?"

- If they supply the details, add the block to the top of the `.md`, then build.
- **If they want to skip, that is a supported outcome, not a fallback.** Build
  as is: the PDF comes out with no cover, content starting on page 1, and the
  footer and artwork on every page. Do not push back.
- **Never invent a title, author, or date.** A wrong author on a client document
  is worse than no cover page. Do not promote the first heading into a title
  either; that heading is body content.

A document that has a title but should still skip the cover can set
`cover: false` in its frontmatter.

## Build hints, and how to handle them

The build prints `hint:` lines for common authoring mistakes that are otherwise
invisible until someone reads the finished PDF. They never stop the build.

**Advise, do not enforce.** Build the document, deliver the PDF, then mention
what you noticed in a sentence or two and offer to fix it. Do not rewrite the
author's text unasked, do not withhold the PDF, and if they say they meant it,
drop it and do not raise it again for that document.

Two cases deserve a mention even without a hint, because the author usually
cannot see them coming:

- **Emoji render as empty boxes.** The bundled fonts carry no emoji glyphs and
  the build ignores system fonts. This one is worth stating plainly, since the
  output is visibly broken rather than merely suboptimal. A bold `**Label:**`
  gives the same visual anchor at the start of a line.
- **Adjacent lines merge into one paragraph.** A stack of `Location:` /
  `Work:` / `Languages:` lines becomes a single run-on block. A blank line
  between them is the whole fix. This is almost never intended, so it is worth
  raising every time.

If asked how to make a plain document look richer, reach for what the template
already has before suggesting anything else: bold labels at the start of a line,
a `>` block as a callout with an accent rule, a table for anything genuinely
tabular, and headings named after what they cover rather than repeated generic
words like "Project".

## Markdown that is supported

Headings, bold and italic, bullet and numbered lists, blockquotes, inline code,
fenced code blocks with syntax highlighting, links, images, and pipe tables.

Tables need the row of dashes under the header, and support alignment colons:

```markdown
| Item | Qty | Amount |
| :--- | :---: | ---: |
| Licences | 12 | 4,800 |
```

**Table width** is the one layout choice available. By default columns are sized
to their contents. To make every table in a document span the full text width,
add `tables: full` to that document's frontmatter.

## The design is fixed

The template is the Serokell house style. Do not edit it to satisfy a request.

Refuse, and say the design is locked, if asked to change the accent colour or
any colour, the fonts or sizes, the cover title styling, the mountain artwork or
logo, the page number, the margins, or the styling of headings, code, quotes, or
lists. Those are brand decisions for the owner of the template repository, not
something to action from a document-writing session.

Table width, above, is the only exception.

## Checking the result

A clean compile is not proof the document looks right. If the change was more
than adding text, look at the rendered pages:

```bash
pdftoppm -png -r 110 output.pdf /tmp/page   # then read /tmp/page-N.png
```
