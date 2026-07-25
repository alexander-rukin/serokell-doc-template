# deck.md - the slide authoring format

One markdown file describes a whole deck: which layout each slide uses plus its
text. Edit the text, rerun `build-deck.sh`, get the PDF back in seconds. Same
file, same result on any machine. You never touch Typst.

```
./build-deck.sh decks/my-deck.md        # -> decks/my-deck.pdf
```

Normally you do not write this file by hand - you tell Claude what the deck is
about and it composes it (see `skills/serokell-slides/SKILL.md`). This document
is the reference for reading and editing the result.

## Shape

```
---                      # optional deck settings (key: value)
theme: light             # light (default) or dark
---

@cover                   # every slide starts with @<layout> [key=value ...]
# Big title              #  '# text'  -> the slide's headline / big line
subtitle: One-liner      #  'key: value'  -> a named field
meta: Serokell · 2026

@bullets
# Heading
lead: optional lead line
- Label | supporting text   #  '- item'  -> a list item
- Another | and its text    #  ' | ' splits an item into parts

@split image=assets/photo.png
# Heading
Plain prose here becomes the body.
```

- A slide runs from its `@layout` line to the next `@` (or end of file).
- `# ...` is the headline (or the big text on statement / stat / quote / closing).
- `- ...` are items. `|` splits an item into its parts - what the parts mean
  depends on the layout (see the table).
- `key: value` sets a named field (only the known keys below; any other `word:`
  in prose is left alone).
- Everything else is body prose.
- Options ride on the `@` line: `@split image=assets/x.png`, `@mobile-showcase n=2`.
- Text is literal - write single hyphens, arrows like `->`, parentheses freely.
  (Inline markdown bold/italic is not interpreted.)
- Cyrillic renders in the bundled Golos Text (Latin stays Google Sans Flex).
- Every slide except the cover/closing carries a footer: slide number left,
  small Serokell mark right. Set `theme: dark` for the dark palette.

## Length matters more than it looks

A slide frame has a fixed height. Too much text does **not** spill onto a second
page - it is silently clipped at the top and bottom edge. The generator warns
when a field is over the layout's comfortable budget:

```
warning: slide 7 (@split): the body text is 900 chars, the layout holds about 420
```

Treat every such warning as a real defect: shorten the text or split the slide.

## Layouts

### Opening, closing, single idea

| `@layout` | headline `#` | fields | items `-` |
|-----------|--------------|--------|-----------|
| `@cover` | title | `subtitle:` `meta:` | - |
| `@section` | section title | - | - |
| `@statement` | the big line | `sub:` | - |
| `@callout` | the pulled-out line (red rule) | `sub:` | - |
| `@quote` | the quote, no closing period | `who:` | - |
| `@highlight` | short label (left) | - | prose = the paragraph on the right |
| `@closing` | the final line | `sub:` | - |

### Text and structure

| `@layout` | headline `#` | fields | items `-` |
|-----------|--------------|--------|-----------|
| `@agenda` | heading | - | `- Section name` (2-8) |
| `@bullets` | heading | `lead:` | `- Label \| text`, or a bare line |
| `@two-col` | heading | - | exactly 2 x `- Label \| text` |
| `@columns` | heading | `lead:` | 2-4 x `- Label \| text` (open page) |
| `@cards` | heading | `lead:` | 2-4 x `- NAME \| body` (grey cards) |
| `@feature-grid` | heading (left) | `lead:` | exactly 4 x `- Label \| text` |
| `@steps` | heading | - | 2-5 x `- step text` (numbered cards) |
| `@compare` | heading | - | exactly 2 x `- HEAD \| body` |
| `@table` | heading | `head: A \| B \| C` | one row per `- a \| b \| c` |
| `@code` | heading | `caption:` | a ```` ```lang ... ``` ```` fence |

### Numbers

| `@layout` | headline `#` | fields | items `-` |
|-----------|--------------|--------|-----------|
| `@stat` | the one big number | `caption` = prose, `sub:` | - |
| `@kpis` | heading | - | 2-4 x `- 98% \| label` |
| `@metric-cols` | heading | - | 2-4 x `- 40% \| paragraph` |
| `@metric-grid` | heading (left) | `desc:` | exactly 4 x `- 40% \| label` |
| `@metric-list` | heading (left) | `lead:` | 2-4 x `- 40% \| Label \| description` |

### Diagrams and time

| `@layout` | headline `#` | fields | items `-` |
|-----------|--------------|--------|-----------|
| `@timeline` | heading | - | 2-5 x `- Stage \| description` |
| `@roadmap` | heading | - | 3-6 x `- Date \| what happened` |
| `@matrix` | heading (left) | `desc:` `x: left \| right` `y: top \| bottom` | exactly 4 (TL, TR, BL, BR) |
| `@venn` | heading (left) | `desc:` | exactly 3 (left, overlap, right) |
| `@nested` | heading (left) | `desc:` | 2-4 rings, outermost first |
| `@funnel` | heading (left) | `desc:` | 3-5 segments, widest first |

### People

| `@layout` | headline `#` | fields | items `-` |
|-----------|--------------|--------|-----------|
| `@testimonial` | the quote | `name:` `loc:` | - |
| `@testimonials` | - | option `avatars=no` | 2-4 x `- quote \| Name · Place` |
| `@team` | heading | option `perrow=6` | 2-12 x `- Name \| role` |

### Visuals

| `@layout` | headline `#` | fields | items `-` |
|-----------|--------------|--------|-----------|
| `@split` | heading | `image=path` or `label:`, option `bleed=yes`; prose = body | - |
| `@image-row` | heading | - | 2-3 x `- path.png \| Label \| description` |
| `@image-full` | caption (or `caption:`) | `image=path` | - |
| `@mobile-showcase` | heading | option `n=1..3` phones; prose = body | - |
| `@desktop-showcase` | heading | prose = body | - |
| `@annotated` | heading | `image=path` | 1-4 x `- left\|right \| 40 \| Label` |

Leave the image path empty (`- | Label | text`) to get the grey placeholder at
the same size - useful while the screenshot does not exist yet. Pointing at a
file that is not there is a different thing and stops the build, naming the
file: a typo in a path should not quietly become a grey box in a client deck.

Image paths are relative to the deck and must stay inside its folder. `../` is
refused - the build copies what a deck points at, and a deck is something people
send each other.

## The whole catalog, rendered

`decks/all-layouts.md` is a deck with one slide per layout. Build it to see
every layout in both themes - it doubles as the smoke test after any change:

```
./build-deck.sh decks/all-layouts.md
THEME=dark ./build-deck.sh decks/all-layouts.md decks/all-layouts-dark.pdf
```

## Regenerate

Edit the `.md`, then:

```
./build-deck.sh decks/your-deck.md
```

The layout library (`src/slides.typ`) and brand assets stay locked; you only ever
touch the deck's markdown.
