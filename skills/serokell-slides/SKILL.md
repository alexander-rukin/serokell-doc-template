---
name: serokell-slides
description: Compose a Serokell-branded slide deck (16:9 PDF) from a brief. The human gives topic + intent, the assistant composes each slide by picking a layout from slides.typ - it does NOT ask the human to encode layout in markdown. Use when asked to build/continue a Serokell presentation or slide deck.
---

# Serokell slide system

Slides are not documents. In a document the layout is constant, so plain
markdown is enough - the brand accretes automatically (that is the doc-template
job). In a deck the **layout carries the meaning**: the same sentence set big and
centred, pinned left, or beside an image is three different statements. So the
human must NOT pre-encode layout in text. Instead:

1. Human gives a brief - topic, audience, rough length, tone - plus notes or
   intent per point ("this is the punchline", "here show before/after").
2. The assistant composes the whole deck: pick a layout per slide from the
   catalog below, place the accent, arrange the content.
3. Human reviews the rendered PDF and edits **in words**: "slide 3 bigger",
   "drop slide 6", "make this a two-column", "add a stat slide with X".
4. Rebuild. Repeat until they are happy.

The brand shell is locked and reused from the doc-template: same tokens, same
Google Sans Flex optical fonts, the same mountain artwork (which carries the
Serokell mark). A deck is therefore itself an example of the house style.

## Files

- `slides.typ` - the layout library. One `#let` per layout. Reusable, locked,
  production-clean. This is the "template" - a brand change is one file.
- `gallery.typ` - a demo deck, one slide per layout, faint mono corner tag
  naming each. Render it to see the whole visual vocabulary.

Both depend on the doc-template's `assets/` (the two `footer-mountains-*.png`
and the `assets/fonts/` optical families). Build from a checkout of
`serokell-doc-template` (or any dir that has that `assets/`).

## Build

```
typst compile --font-path assets/fonts --ignore-system-fonts deck.typ deck.pdf
```

Copy `slides.typ` next to your `deck.typ` inside the repo (so `assets/` resolves)
and `#import "slides.typ": *` at the top of the deck.

## Layout catalog

Each takes an optional `tag: "..."` (faint corner label, gallery only - omit in a
real deck).

| Layout | Call | Use for |
|--------|------|---------|
| Cover | `cover(title, subtitle: .., meta: ..)` | deck opener |
| Section | `section("01", [Title])` | section divider, big number |
| Statement | `statement([one big line], sub: ..)` | a single claim, with air |
| Bullets | `bullets([Heading], ([a],[b],..), lead: ..)` | linear list of equals |
| Two columns | `two-col([Heading], [left], [right])` | two parallel streams |
| Split | `split([Heading], [text], img: "path.png")` or `.. label: [placeholder]` | text + a visual (image or placeholder panel) |
| Stat | `stat([98%], [caption], sub: ..)` | one big number / value anchor |
| Quote | `quote-slide([text], who: [name])` | a pull quote with accent spine |
| Compare | `compare([Heading], [A head],[A body],[B head],[B body])` | before/after, two panels |
| Code | ```code-slide([Heading], ```sh ..```, caption: ..)``` | a mono block |
| Steps | `steps([Heading], ([s1],[s2],[s3],[s4]))` | numbered horizontal process |
| Cards | `cards([Heading], (([name],[body]),..), lead: ..)` | 3-4 labelled cards |
| Closing | `closing([final line], sub: ..)` | last slide, over the mountains |

## Gotchas (Typst authoring)

- **Verify the rendered pixels, not just a clean compile.** After any layout
  change rasterise (`pdftoppm -png -r 72 deck.pdf p`) and look. A slide silently
  spilling to a second page is the common failure - the deck should have exactly
  one page per `#..` call. If page count exceeds slide count, a slide overflowed:
  shrink copy / font / gaps.
- **A bare `-` or `*` at the start of markup content becomes a list / strong.**
  An attribution like `who: [- name]` renders as a bullet. Drop the leading dash
  or pass plain text.
- **`*` inside markup opens strong emphasis** - escape as `\*` (e.g. `content/\*.md`).
- **Tall display glyphs blow up flow spacing** - the `stat` number is pinned in a
  fixed-height `box(..align(bottom, ..))` so its oversized line-box ascent does
  not push the caption down. Keep that pattern if you add big-number layouts.
- **Content overflows on ~142mm height fast.** Body copy 12.5-14pt, keep bullets
  to 4-5, statements to one or two lines.
