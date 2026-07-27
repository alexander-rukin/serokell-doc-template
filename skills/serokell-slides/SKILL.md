---
name: serokell-slides
description: Build a Serokell-branded slide deck (16:9 PDF) from a brief. The person says what the deck is about and hands over their text or notes; the assistant composes the slides - picking a layout per slide - and renders the PDF. Use whenever someone asks for a presentation, slide deck, pitch, talk, or wants slides made or edited from text.
---

# Serokell slide deck

The person brings a topic and their text. You compose the deck and render it.
They never write layout markup, never open Typst, and never touch the brand.

Slides are not documents. In a document the layout is constant, so plain
markdown is enough. In a deck the **layout carries the meaning**: the same
sentence set big and centred, pinned beside an image, or sliced into cards is
three different statements. So the person must not pre-encode layout in text -
that is your job.

## The loop

1. **They brief you** - topic, audience, roughly how long, plus their notes,
   bullet points, a doc, or just a spoken outline. Anything from three sentences
   to a finished text.
2. **You compose the whole deck** - split the material into slides, pick a
   layout per slide (the catalog is below), write each slide's text, and save it
   as a `deck.md` in *their* working directory (never inside the template).
3. **You render and look at it** - build the PDF, rasterise it, and check every
   page with your own eyes before handing it over.
4. **You hand over the PDF** and say what you did: how many slides, what the arc
   is, anything you cut or had to invent.
5. **They edit in words** - "slide 3 as two columns", "drop slide 6", "make the
   numbers a KPI row", "shorter". You edit `deck.md` and rebuild in seconds.

Ask before starting only if the brief leaves you unable to write the first
slide - usually the audience or the goal. One question, not a questionnaire.

## Building

If the template is installed as a plugin:

```bash
"${CLAUDE_PLUGIN_ROOT}/render-deck.sh" path/to/deck.md          # -> deck.pdf next to it
THEME=dark "${CLAUDE_PLUGIN_ROOT}/render-deck.sh" path/to/deck.md
```

From a checkout of the repository, the same thing with `./render-deck.sh`.
(`./build-deck.sh decks/x.md` also exists - it builds inside the checkout and is
for working on the template itself.)

`typst` must be on PATH; the script says how to install it if it is missing.
Fonts and artwork are bundled, so the PDF is identical on every machine.

## Verify before you hand it over

Two failures survive a clean compile:

- **Too much text is CLIPPED, not reflowed.** A slide frame has a fixed height;
  overflowing text is cut off at the top and bottom edge. The builder warns
  (`warning: slide 7 (@split): the body text is 900 chars ...`) - every such
  warning is a real defect. Shorten the text or split the slide.
- **A layout can flow onto a second page.** The builder compares slide count to
  page count and warns. One page per slide, always.

Then look:

```bash
pdftoppm -png -r 72 deck.pdf /tmp/deck-page      # one PNG per page
```

Read the pages. You are checking that each slide says what it should, nothing is
cut off, and the deck reads as one document. Never hand over a deck you have not
looked at.

## Composing: which layout says what

Choose by what the slide is *doing*, not by what fits.

| The slide is... | Use |
|---|---|
| the opener | `@cover` |
| a divider between parts | `@section` |
| the deck's map, up front | `@agenda` |
| one claim, given air | `@statement` |
| one remark that must not be missed | `@callout` |
| someone's words | `@quote`, or `@testimonial` for a client |
| a list of equals | `@bullets` (each item `Label \| its line`) |
| two parallel streams | `@two-col` |
| three or four parallel things | `@columns` (open) or `@cards` (boxed) |
| four features around one idea | `@feature-grid` |
| a process in order | `@steps` |
| before and after | `@compare` |
| structured facts to scan | `@table` |
| one number that anchors everything | `@stat` |
| several headline numbers | `@metric-cols`, `@metric-grid`, `@metric-list` |
| stages over time | `@timeline`, or `@roadmap` for dated history |
| a positioning argument | `@matrix`, `@venn`, `@nested`, `@funnel` |
| the people | `@team`, `@testimonials` |
| text plus a visual | `@split` (image right), `@image-full`, `@image-row` |
| a product screen | `@mobile-showcase`, `@desktop-showcase`, `@annotated` |
| the last word | `@closing` |

Full field reference: `docs/FORMAT.md`. Every layout rendered, one slide each:
`decks/all-layouts.md` - build it when you want to see the whole vocabulary.

## Composing: the habits that make a deck read well

- **One idea per slide.** If a slide needs "and", it is two slides.
- **Short lines.** Roughly: a headline under ~70 characters, a card body under
  ~120, a split body under ~420. The builder tells you when you are over.
- **Vary the rhythm.** Four `@bullets` in a row is a document, not a deck. Break
  text slides with a number, a quote, a diagram, a divider.
- **Spend the accent sparingly.** The red is structural - it lands on section
  numbers, nodes and rules by itself. On top of that you may mark ONE span per
  slide with `*asterisks*`, and only on slides that carry a point worth
  spotlighting - a headline's operative word, the number on a `@stat`. Propose
  the spans when you draft the deck and say which words you marked, so the
  author can move them; they are plain text in the deck.md, not a hidden style.
  A deck where most slides have a red word has no accent at all - if in doubt,
  leave it out. The builder warns at two spans on one slide.
- **Do not invent facts.** No made-up metrics, client names, or dates. If the
  brief has no number for a `@stat` slide, ask for one or use another layout.
- **Placeholders are fine.** An image that does not exist yet renders as a grey
  panel at the right size - leave the path empty and carry on.
- **Cyrillic and Latin both work.** Russian renders in the bundled Golos Text;
  Latin stays Google Sans Flex. No configuration.

## The design is locked

`src/slides.typ` is the Serokell house style: colours, fonts, sizes, spacing tokens,
the mountain artwork, the footer. It has been designed and signed off.

Refuse in-session requests to change the accent colour, fonts, sizes, margins,
artwork or footer, and say the design is locked. Those are brand decisions the
repository owner makes deliberately, not something to action from a passing ask
during a deck-writing session. Composition - which layout, what text, what
order - is entirely open.

If a deck genuinely needs a layout that does not exist, say so plainly rather
than bending an existing one past what it holds.

## Gotchas (when working on the layout library itself)

- **Verify the rendered pixels, not just a clean compile.** Rasterise and look.
- **A bare `-` or `*` at the start of markup content becomes a list / strong.**
  The generator escapes author text, but hand-written Typst needs care.
- **Tall display glyphs blow up flow spacing** - big numbers are pinned in a
  fixed-height box so their line-box ascent does not push the caption down.
  Keep that pattern in any new big-number layout.
