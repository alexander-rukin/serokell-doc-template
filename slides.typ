// =============================================================================
// Serokell slide system - reusable 16:9 layout library.
//
// One brand shell, many slide formats. Reuses the doc-template's design tokens,
// Google Sans Flex optical fonts and the mountain artwork (which carries the
// Serokell mark), so a deck is an example of the house style it presents.
//
// Usage:
//   #import "slides.typ": *
//   #cover([Title], subtitle: [..], meta: [..])
//   #bullets([Heading], ([point], [point], ..))
//   ... one call per slide, in order.
//
// Every layout takes an optional `tag: "..."` that prints a faint corner label -
// used only by the gallery demo; omit it in a real deck.
// =============================================================================

// ---- design tokens (from template.typ) --------------------------------------
#let accent    = rgb("#D92B04")
#let ink       = rgb("#1A1A1A")
#let ink-soft  = rgb("#5A5F66")
#let hairline  = rgb("#DDE1E5")
#let code-bg   = rgb("#F5F6F7")
#let panel-bg  = rgb("#F0EEF0")

// ---- fonts (per optical size, exactly as the doc template) ------------------
#let font-emoji   = "Noto Color Emoji"
#let font-display = ("Google Sans Flex 120pt", font-emoji) // cover / big numbers
#let font-heading = ("Google Sans Flex 36pt", font-emoji)  // slide titles
#let font-body    = ("Google Sans Flex 24pt", font-emoji)  // body copy
#let font-mono    = ("JetBrains Mono", font-emoji)

// ---- geometry (16:9) --------------------------------------------------------
#let W  = 254mm
#let H  = 142.875mm
#let MX = 22mm

// ---- base text --------------------------------------------------------------
#set text(font: font-body, size: 14pt, fill: ink, lang: "ru")
#set par(leading: 0.6em)

// ---- shared pieces ----------------------------------------------------------
#let art-band(peak: 42mm, x: MX) = place(bottom + left, dx: -x, box(width: W, height: peak, {
  place(bottom + left,  image("assets/footer-mountains-left.png",  width: W))
  place(bottom + right, image("assets/footer-mountains-right.png", height: peak))
}))

#let mono(s) = box(fill: code-bg, inset: (x: 3pt, y: 1pt), radius: 2pt,
  text(font: font-mono, size: 10.5pt, s))

#let bullet-list(items, gutter: 5mm) = grid(
  columns: (5mm, 1fr), column-gutter: 0mm, row-gutter: gutter,
  ..items.map(x => (text(fill: accent, weight: "bold")[•], x)).flatten()
)

#let head(title) = {
  box(width: 16mm, height: 3pt, fill: accent)
  v(5mm)
  text(font: font-heading, size: 23pt, weight: "bold", fill: ink, title)
  v(7mm)
}

// The single page primitive every layout builds on.
#let slide-raw(body, mtop: 16mm, mbot: 14mm, x: MX, tag: none) = page(
  width: W, height: H, margin: (x: x, top: mtop, bottom: mbot), fill: white,
  {
    if tag != none {
      place(top + right, text(font: font-mono, size: 8pt, fill: hairline)[#tag])
    }
    body
  },
)

// =============================================================================
// LAYOUTS
// =============================================================================

// 1. Cover - deck opener.
#let cover(title, subtitle: none, meta: none, tag: none) = slide-raw(mtop: 26mm, mbot: 0mm, x: 20mm, tag: tag, {
  box(width: 18mm, height: 3.5pt, fill: accent)
  v(9mm)
  text(font: font-display, size: 34pt, weight: "semibold", fill: ink)[#par(leading: 0.3em, justify: false, title)]
  if subtitle != none {
    v(6mm)
    text(font: font-heading, size: 15pt, weight: "regular", fill: ink-soft)[#par(leading: 0.5em, justify: false, subtitle)]
  }
  if meta != none {
    v(5mm)
    text(font: font-body, size: 10.5pt, fill: ink-soft, meta)
  }
  art-band(peak: 40mm, x: 20mm)
})

// 2. Section divider - big number + section title over the range.
#let section(no, title, tag: none) = slide-raw(mtop: 30mm, mbot: 0mm, tag: tag, {
  text(font: font-display, size: 80pt, weight: "black", fill: accent, no)
  v(1mm)
  text(font: font-heading, size: 30pt, weight: "bold", fill: ink, title)
  art-band(peak: 44mm)
})

// 3. Statement - one big sentence.
#let statement(body, sub: none, tag: none) = slide-raw(mtop: 24mm, mbot: 0mm, tag: tag, {
  box(width: 16mm, height: 3.5pt, fill: accent)
  v(9mm)
  text(font: font-heading, size: 32pt, weight: "bold", fill: ink)[#par(leading: 0.32em, justify: false, body)]
  if sub != none {
    v(6mm)
    text(font: font-body, size: 13.5pt, fill: ink-soft)[#par(leading: 0.5em, justify: false, sub)]
  }
  art-band(peak: 44mm)
})

// 4. Bullets - heading + list, with an optional lead line.
#let bullets(title, items, lead: none, tag: none) = slide-raw(tag: tag, {
  head(title)
  if lead != none {
    text(size: 13.5pt, fill: ink-soft, lead)
    v(6mm)
  }
  set text(size: 14pt)
  bullet-list(items)
})

// 5. Two columns of text.
#let two-col(title, left, right, tag: none) = slide-raw(tag: tag, {
  head(title)
  grid(columns: (1fr, 1fr), column-gutter: 12mm, align: top,
    text(size: 13.5pt, fill: ink, left),
    text(size: 13.5pt, fill: ink, right))
})

// 6. Split - text left, a visual panel right (image, or a labelled placeholder).
#let split(title, body, img: none, label: none, tag: none) = slide-raw(tag: tag, {
  head(title)
  grid(columns: (1fr, 96mm), column-gutter: 12mm, align: top,
    text(size: 13.5pt, fill: ink, body),
    box(width: 100%, height: 70mm, radius: 4pt, clip: true,
      fill: if img == none { panel-bg } else { none },
      stroke: if img == none { (left: 2pt + accent) } else { none },
      {
        if img != none {
          image(img, width: 100%, height: 100%, fit: "cover")
        } else {
          place(center + horizon, text(font: font-body, size: 11pt, fill: ink-soft,
            if label != none { label } else { [визуал] }))
        }
      }))
})

// 7. Stat - one huge accent number.
#let stat(number, caption, sub: none, tag: none) = slide-raw(mtop: 30mm, tag: tag, {
  box(width: 16mm, height: 3.5pt, fill: accent)
  v(10mm)
  // Pin the tall display glyphs into a fixed-height box so their oversized
  // line-box ascent does not blow up the flow spacing below.
  box(height: 26mm, align(bottom,
    text(font: font-display, size: 62pt, weight: "black", fill: accent, number)))
  v(9mm)
  text(font: font-heading, size: 19pt, weight: "bold", fill: ink, caption)
  if sub != none {
    v(5mm)
    text(font: font-body, size: 12.5pt, fill: ink-soft, sub)
  }
})

// 8. Quote - pull quote with an accent spine.
#let quote-slide(body, who: none, tag: none) = slide-raw(mtop: 30mm, tag: tag, {
  block(stroke: (left: 3pt + accent), inset: (left: 10mm, y: 2mm), {
    text(font: font-heading, size: 26pt, weight: "medium", fill: ink)[#par(leading: 0.36em, justify: false)[«#body»]]
    if who != none {
      v(7mm)
      text(font: font-body, size: 12pt, weight: "semibold", fill: ink-soft, who)
    }
  })
})

// 9. Compare - two panels side by side (e.g. before / after).
#let compare(title, a-head, a-body, b-head, b-body, tag: none) = slide-raw(tag: tag, {
  head(title)
  grid(columns: (1fr, 1fr), column-gutter: 9mm, align: top,
    box(width: 100%, fill: code-bg, radius: 4pt, stroke: (left: 2pt + ink-soft), inset: (x: 12pt, y: 12pt), {
      text(font: font-mono, size: 10.5pt, weight: "bold", fill: ink-soft, a-head)
      v(5pt)
      text(size: 12.5pt, fill: ink, a-body)
    }),
    box(width: 100%, fill: code-bg, radius: 4pt, stroke: (left: 2pt + accent), inset: (x: 12pt, y: 12pt), {
      text(font: font-mono, size: 10.5pt, weight: "bold", fill: accent, b-head)
      v(5pt)
      text(size: 12.5pt, fill: ink, b-body)
    }))
})

// 10. Code - a mono block on a slide.
#let code-slide(title, code, caption: none, tag: none) = slide-raw(tag: tag, {
  head(title)
  block(width: 100%, fill: code-bg, radius: 4pt, stroke: (left: 2pt + accent), inset: 12pt,
    text(font: font-mono, size: 11pt, fill: ink)[#code])
  if caption != none {
    v(6mm)
    text(size: 12.5pt, fill: ink-soft, caption)
  }
})

// 11. Steps - numbered horizontal process with arrows.
#let steps(title, items, tag: none) = slide-raw(tag: tag, {
  head(title)
  v(3mm)
  let n = items.len()
  let cols = ()
  for i in range(n) {
    cols.push(1fr)
    if i < n - 1 { cols.push(8mm) }
  }
  let cells = ()
  for (i, it) in items.enumerate() {
    cells.push(box(width: 100%, fill: code-bg, radius: 4pt, stroke: (top: 2pt + accent), inset: (x: 11pt, y: 12pt), {
      text(font: font-display, size: 22pt, weight: "black", fill: accent, str(i + 1))
      v(4pt)
      text(size: 12pt, fill: ink, it)
    }))
    if i < n - 1 {
      cells.push(align(horizon + center, text(size: 18pt, weight: "bold", fill: accent)[→]))
    }
  }
  grid(columns: cols, column-gutter: 0mm, align: horizon, ..cells)
})

// 12. Cards - a row of labelled cards.
#let cards(title, items, lead: none, tag: none) = slide-raw(tag: tag, {
  head(title)
  if lead != none {
    text(size: 13.5pt, fill: ink-soft, lead)
    v(7mm)
  }
  grid(columns: items.map(x => 1fr), column-gutter: 7mm, align: top,
    ..items.map(it => box(width: 100%, fill: code-bg, stroke: (left: 2pt + accent), radius: (right: 3pt), inset: (x: 11pt, y: 10pt), {
      text(font: font-mono, size: 11pt, weight: "bold", fill: ink, it.at(0))
      v(3pt)
      text(size: 11.5pt, fill: ink-soft, it.at(1))
    })))
})

// 13. Closing - final statement over the mountains.
#let closing(body, sub: none, tag: none) = statement(body, sub: sub, tag: tag)
