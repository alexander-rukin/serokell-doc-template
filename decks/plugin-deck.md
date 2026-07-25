---
theme: light
---

@cover
# How we built the Markdown to PDF plugin
subtitle: One source of truth, a branded document every time
meta: Serokell · 23 July 2026

@statement
# Without a template, every document forks the brand.
sub: Colours drift, headings swell, and nobody notices until the brand has dissolved.

@bullets
# The idea
lead: Markdown in. A branded PDF out.
- The author writes plain Markdown and never touches layout
- The brand is applied for them, the same way, every time
- Changing the brand is one file, reviewed once

@cards
# Three files, one role each
lead: Separating those roles is the whole trick - it keeps the author out of layout code for good.
- src/template.typ | Every token, the cover, the footer. The brand lives here and nowhere else.
- render / main | The shared wrapper: path, frontmatter, body. Never edited per document.
- content/md | The author's territory. Plain Markdown, nothing else.

@bullets
# Lock the design, leave one knob
lead: A template that allows per-document edits stops being a template - every document becomes a fork.
- The repository refuses edits to colour, fonts, artwork and margins
- Exactly one setting: table width, auto or full
- The list of refusals is written into the assistant's instructions

@bullets
# Every difficulty was a quiet one
lead: Each compiled without error and produced a valid PDF. They were visible only in the pixels.
- A show rule that rebuilds its own element recurses forever - build the table as a grid
- Wrapping raw in par silently drops code blocks - use a content block
- page(background) leaks onto the cover - pass it background none explicitly
- A clean compile proves nothing - rasterise the output and look at it

@bullets
# One source, the same PDF, any machine
- Fonts live in the repository, with ignore-system-fonts, so nothing is silently substituted
- Google Sans Flex: one family per optical size
- Emoji through Noto Color Emoji - vector, sharp in print, no empty boxes

@closing
# This deck was built with the tool it describes.
sub: The same tokens, fonts and mountains. The most convincing sample of the output is the output.
