# deck.md - the slide authoring format

One markdown file describes a whole deck: which layout each slide uses plus its
text. You edit text here and rerun `build-deck.sh` to regenerate the PDF in
seconds. Same file, same result on any machine. You never touch Typst.

```
./build-deck.sh decks/plugin-deck.md        # -> decks/plugin-deck.pdf
```

## Shape

```
---                      # optional deck settings (key: value)
theme: light             # light (default) or dark
---

@cover                   # every slide starts with @<layout> [key=value ...]
# Big title              #  '# text'  -> the slide's headline / big line
subtitle: One-liner      #  'key: value'  -> a named field
meta: Serokell . 2026

@bullets
# Heading
lead: optional lead line
- first point            #  '- item'  -> a list item
- second point

@split image=assets/photo.png
# Heading
Plain prose here becomes the body.
```

- A slide runs from its `@layout` line to the next `@` (or end of file).
- `# ...` is the headline (or the big text on statement / stat / quote / closing).
- `- ...` are list items.
- `key: value` sets a named field (only known keys below; other `word:` in prose
  is left alone).
- Everything else is body prose.
- Options can also ride on the `@` line: `@split image=assets/x.png`, `@section no=02`.
- Text is literal - write single hyphens, arrows like `->`, parentheses freely.
  (Inline markdown bold/italic is not interpreted in v1.)
- Cyrillic renders in the bundled Golos Text (Latin stays Google Sans Flex).
- Every slide except the cover/closing carries a footer: small Serokell mark
  left, slide number right. Set `theme: dark` for the dark palette.

## Layouts and their fields

| `@layout` | headline `#` | fields | list `-` |
|-----------|-------------|--------|----------|
| `@cover` | title | `subtitle:` `meta:` | - |
| `@section` | title | `no=01` (option) | - |
| `@statement` | the big line | `sub:` | - |
| `@bullets` | heading | `lead:` | bullet points |
| `@two-col` | heading | `left:` `right:` (or two paragraphs) | - |
| `@split` | heading | `image=path` or `label:`; prose = body | - |
| `@stat` | the big number | `caption` = prose, `sub:` | - |
| `@quote` | the quote | `who:` | - |
| `@compare` | heading | - | two items `- HEAD | body` (before, after) |
| `@code` | heading | ` ```lang ... ``` ` fence = code, `caption:` | - |
| `@steps` | heading | - | numbered items |
| `@cards` | heading | `lead:` | items `- NAME | body` |
| `@closing` | the big line | `sub:` | - |

## Regenerate

Edit the `.md`, then:

```
./build-deck.sh decks/your-deck.md
```

The layout library (`slides.typ`) and brand assets stay locked; you only ever
touch the deck's markdown.
