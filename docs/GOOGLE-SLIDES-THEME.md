# Building the same deck theme in Google Slides

Some people will not write Markdown, and a template they cannot use is not a
template. This is the specification for rebuilding the house slide style as a
Google Slides theme, by hand, so those decks still look like ours.

It is a build sheet, not a suggestion: every number here is lifted from
`src/slides.typ`, which stays the canonical brand. Build to these numbers and
the two match; guess at them and they drift within a month.

**Read the trade-off first.** A Slides theme gives up every guarantee the
builder provides - it will not tell you the text overflowed, will not scale a
6 MB photo, will not stop someone dragging a heading 20 pt to the left. What it
buys is that people who work in Slides keep working in Slides. That is a real
gain; just do not expect the file to police itself. See
[What you lose](#what-you-lose-and-how-to-cover-it).

---

## Canvas and units

Set the presentation to **Widescreen 16:9**, which in Slides is exactly
**10 x 5.625 inches = 720 x 405 pt**. Our slide is 254 x 142.875 mm, which is
the same rectangle to the millimetre.

That coincidence is what makes this worth doing properly: **1 mm = 2.8346 pt**,
and because the canvas is the same physical size, **every type size carries over
unchanged**. 45.8 pt here is 45.8 pt there. No rescaling, no "roughly".

Positions below are given in points from the top-left of the slide, which is
what the Slides format sidebar takes.

| Grid value | mm | pt | Used for |
|---|---|---|---|
| Frame margin | 16.9 | **47.9** | every edge - nothing but artwork crosses it |
| Content width | 220.2 | **624.2** | full-width band inside the margins |
| Heading band top | 16.9 | **47.9** | top-anchored headings |
| Content band top (`Y2`) | 45 | **127.6** | where cards, columns, tables start |
| Text column | 95 | **269.3** | one column of running text |
| Second column x | 128.1 | **363.1** | the right column on two-column slides |
| Display measure | 205 | **581.1** | cover, section, statement, quote, closing |
| Card gutter | 6.4 | **18.1** | between cards in a row, any count |
| Card radius | 3 | **8.5** | every rounded surface |
| Card padding | 6.5 | **18.4** | inside a card |
| Footer offset from bottom edge | 6 | **17.0** | page number and mark sit here |

---

## Colours

Two themes. Build the light one first; the dark one is the same geometry with
another palette, so duplicate and recolour.

| Role | Light | Dark |
|---|---|---|
| Page | `#FFFFFF` | `#2A282E` |
| Text | `#000000` | `#F3F4F6` |
| Muted text | `#404040` | `#9AA0A6` |
| Card fill | `#EAEAEE` | `#37363D` |
| Card hairline (0.75 pt) | `#D6D6DD` | `#494851` |
| Code panel | same as card fill | same as card fill |
| Accent | `#D92B04` | `#D92B04` |
| Page-number total | `#B8B8BE` | `#5A5A5E` |

The accent is one colour and it is spent sparingly: **one accented thing per
slide, and not on every slide.** In a heading it is colour alone; in running
text the accented words are bold as well, or the red does not hold.

---

## Type

Both faces are in the Google Fonts catalogue, so they come in through
**More fonts** - nothing to install per machine.

| Role | Font | Size | Weight | Where |
|---|---|---|---|---|
| Display | Google Sans Flex | **45.8 pt** | Bold | cover title, section, statement, the big number, closing |
| Figure | Google Sans Flex | **29.3 pt** | Bold | metric numbers, step numbers |
| Heading | Google Sans Flex | **23.4 pt** | Bold | the working heading on a content slide |
| Label | Google Sans Flex | **15 pt** | Bold | card and column labels |
| Subhead | Google Sans Flex | **15 pt** | Medium | the ONE line under a display hero - never under a 23.4 pt heading |
| Body | Google Sans Flex | **12 pt** | Regular | everything that is a sentence |
| Caption | Google Sans Flex | **9.6 pt** | Regular, muted | attribution, meta, axis labels |
| Code | JetBrains Mono | **11 pt** | Regular | code panels |

Cyrillic falls back to **Golos Text** (Google Sans Flex has none). Set it as the
font on any Russian text box.

Line spacing: Slides works in multipliers rather than absolute leading. Start at
**1.0** for display sizes and **1.15** for body, then compare against a rendered
PDF from this repo and adjust once - it is the one value here that has to be
matched by eye rather than by number.

### The gaps between elements

Each gap is a fraction of the size of the element above it, which is why a big
heading gets more air than a small one. Absolute values for a build:

| Between | pt |
|---|---|
| Display hero -> its subhead | **29.8** |
| Heading -> body, list or lead | **24.6** |
| Label -> its body (inside a card, or a column block) | **13.5** |
| Label -> its body (tight pairing on the open page) | **6.8** |
| Big figure -> its label | **22.0** |
| Step number -> its text | **17.6** |
| Subhead -> the small meta line | **13.5** |
| Between list items | **25.5** |

---

## The master

Everything below goes on the master, so no author has to place it.

**Background art.** `assets/brand-mountains.png`, full bleed, cropped to fill.
Set the image transparency to **93%** on light and **94%** on dark - that is the
7% / 6% the builder uses, and the different numbers are deliberate: the snow is
light, so the same value that whispers on white shouts on a dark page. The
**cover has no background art** - it carries the same range at full strength,
and doubling it costs the cover its job.

**Footer**, on every layout except the cover:

- Serokell mark, bottom right, height **14.2 pt**, its baseline **17.0 pt** off
  the bottom edge. Dark mark on light, light mark on dark.
- Page number, bottom left, same 17.0 pt line, **10 pt Medium**: the current
  number in full text colour, then " / " and the total in the muted grey from
  the table above.

**Accent bar** on the cover only: a **45.4 x 3 pt** red rectangle at the
top-left corner of the content grid (47.9, 47.9).

---

## The layouts to build

Twelve, not thirty-seven. The library has more because a generator can afford
them; a human picking from a menu cannot. These twelve cover what real decks
use - add another only when a deck actually needs it.

Coordinates are the top-left corner of each placeholder, in points.

### 1. Cover
- Background: `brand-footer-long.png`, full width, flush to the bottom edge
- Accent bar at (47.9, 47.9)
- Title: (47.9, **155.9**), width 581.1, display 45.8
- Subtitle: 29.8 pt below the title, subhead 15 Medium
- Meta line: 13.5 pt below that, caption 9.6 muted
- Mark: bottom right as on the master, but the light version - it sits on the peak

### 2. Section divider
- Single display line, vertically centred, x 47.9, width 581.1
- Optional eyebrow above it: **12 pt Regular in accent red, letter-spacing
  0.05 em**, with 6.8 pt clear beneath. It is a service line, not a second
  heading, which is why it is neither bold nor grey.
- No accent bar - the red bar belongs to the cover alone, so it reads as "the
  deck starts here" rather than as a repeating mark

### 3. Statement
- Same block as the section, plus an optional subhead 29.8 pt under the line

### 4. Heading + body
- Heading: (47.9, 47.9), width 624.2, 23.4 Bold
- Body: 24.6 pt under it, width 269.3, body 12

### 5. Heading + list
- Heading and lead: left column, vertically centred, width 269.3
- Items: right column at x **363.1**, width 269.3
- Each item is a label (15 Bold), 13.5 pt, then its body (12)
- **25.5 pt** between items

### 6. Two columns
- Heading: (47.9, 47.9), width 624.2
- Columns at x 47.9 and 363.1, both starting at y **127.6**, width 269.3 each

### 7. Cards (2-4)
- Heading band as above; optional lead 24.6 pt under it
- Cards start at y **127.6**, height **175.7 pt**, radius 8.5, padding 18.4
- Widths, gutter 18.1: two cards **303.0**, three **196.0**, four **142.4**
- Inside: label 15 Bold, 13.5 pt, body 12

### 8. Big number
- The number in display 45.8 (or 29.3 in a row of them), vertically centred
- Caption 29.8 pt below; optional muted meta 13.5 pt under that

### 9. Metric row (2-4)
- Heading band as above
- Row starts at y **170.1**, gutter 12 mm = **34.0 pt**
- Widths: two **295.1**, three **185.4**, four **130.5**
- Inside: figure 29.3 Bold, **22.0 pt**, description 12

### 10. Text and a visual
- Text column: x 47.9, width 269.3, vertically centred
- Image: x **363.1**, y 47.9, a **309 x 309 pt** square, radius 8.5
- Full-bleed variant: image from x **374.2** to the right edge, top to bottom, no radius

### 11. Quote
- The quote in heading size 23.4, width 581.1, vertically centred
- Attribution 24.6 pt below, body 12 muted - not a subhead

### 12. Closing
- One display line, vertically centred, width 581.1
- Optional subhead 29.8 pt below

---

## What you lose, and how to cover it

The builder enforces four things that a Slides file cannot. Put them in the
deck-review habit instead:

| The builder does | In Slides you must |
|---|---|
| Warns when text exceeds what a layout holds - overflow is clipped, never reflowed | Look at every slide at 100%; if the text box has been resized, the slide is over budget |
| Scales photographs to 2600 px on the way in | Insert photos already exported at a sensible size, or the file becomes unmailable |
| Guarantees identical spacing on every slide | Never nudge a placeholder; if a slide needs a different shape, it needs a different layout |
| Refuses to change fonts, colours and margins per deck | Same rule, by agreement rather than by code |

---

## Keeping the two from drifting

One rule, and it is the whole reason this file exists: **the repository is the
brand, the Slides theme is a copy of it.** A copy that nobody tracks becomes a
second opinion.

- Name the theme file with the version it was built from - `Serokell deck theme
  0.6` - so anyone can tell whether it is current.
- When this repository releases a change that touches colour, type or spacing,
  the CHANGELOG says so; the theme is updated by hand and its version bumped.
- Never fix a brand detail in the theme only. Fix it here, then copy it across.

---

## Build checklist

1. New presentation, Widescreen 16:9 (720 x 405 pt).
2. Add Google Sans Flex, Golos Text and JetBrains Mono via **More fonts**.
3. Master: background art at 93% transparency, footer mark and page number,
   colours and text styles from the tables above.
4. Build the twelve layouts to the coordinates above.
5. Duplicate the whole theme, recolour for dark, set the art to 94%.
6. Rebuild `decks/all-layouts.md` from this repo as a PDF and compare slide for
   slide - the sizes should match exactly, the spacing to within a point or two.
7. Put a copy in the template gallery, or share one file that people copy.
