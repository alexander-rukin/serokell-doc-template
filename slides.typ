// =============================================================================
// Serokell slide system - reusable 16:9 layout library.
//
// One brand shell, many slide formats. Reuses the doc-template's design tokens,
// Google Sans Flex optical fonts (Cyrillic via a bundled Golos Text fallback)
// and the mountain artwork with the Serokell mark.
//
// Theme:  compile with  --input theme=dark  (default light).
//
// Usage:
//   #import "slides.typ": *
//   #cover([Title], subtitle: [..])
//   ... one call per slide, in order.
//
// Every layout takes an optional `tag: "..."` (faint corner label, gallery only).
// =============================================================================

// ---- theme ------------------------------------------------------------------
#let theme = sys.inputs.at("theme", default: "light")
#let dark  = theme == "dark"

// ---- design tokens ----------------------------------------------------------
#let accent   = rgb("#D92B04")
#let bg       = if dark { rgb("#141518") } else { white }
#let ink      = if dark { rgb("#F3F4F6") } else { rgb("#1A1A1A") }
#let ink-soft = if dark { rgb("#9AA0A6") } else { rgb("#5A5F66") }
#let hairline = if dark { rgb("#2E3236") } else { rgb("#DDE1E5") }
#let code-bg  = if dark { rgb("#1E2024") } else { rgb("#F5F6F7") }
#let panel-bg = if dark { rgb("#24262B") } else { rgb("#F0EEF0") }
#let mark-img = if dark { "assets/serokell-mark-light.png" } else { "assets/serokell-mark-dark.png" }

// ---- fonts (Latin: Google Sans optical; Cyrillic fallback: Golos Text) ------
#let font-emoji   = "Noto Color Emoji"
#let font-display = ("Google Sans Flex 120pt", "Golos Text", font-emoji)
#let font-heading = ("Google Sans Flex 36pt", "Golos Text", font-emoji)
#let font-body    = ("Google Sans Flex 24pt", "Golos Text", font-emoji)
#let font-mono    = ("JetBrains Mono", "Golos Text", font-emoji)

// ---- geometry (16:9) --------------------------------------------------------
#let W  = 254mm
#let H  = 142.875mm
#let MX = 22mm

// ---- type scale (single source of truth for sizes) --------------------------
// A modular-ish scale so every layout draws from the same set instead of ad-hoc
// point sizes. Change the scale here and the whole deck follows.
#let fs-mega    = 78pt   // section divider number
#let fs-display = 62pt   // hero figure / stat number
#let fs-hero    = 34pt   // cover title
#let fs-h1      = 30pt   // statement, section title, closing
#let fs-quote   = 26pt   // pull quote
#let fs-h2      = 23pt   // content-slide heading (head)
#let fs-h3      = 19pt   // stat caption
#let fs-lead    = 15pt   // lead line under a heading
#let fs-body    = 14pt   // default body
#let fs-small   = 13pt   // secondary body / column text
#let fs-caption = 10.5pt // meta / captions

// ---- brand accent tick + readable measure -----------------------------------
#let bar-w = 16mm        // the red accent bar - one width everywhere
#let bar-h = 3pt         // one thickness everywhere
#let accent-bar = box(width: bar-w, height: bar-h, fill: accent)
#let MEASURE = 172mm     // cap long-form line length (~65-75 chars) for readability

// ---- base text --------------------------------------------------------------
#set text(font: font-body, size: fs-body, fill: ink, lang: "ru")
#set par(leading: 0.6em)

// ---- brand artwork (bookends) -----------------------------------------------
// The mountain range with the Serokell mark, veiled into the page background so
// the top fades away. The veil colour is the theme background, so it works on
// both light and dark.
#let art-band(peak: 44mm, x: MX) = place(bottom + left, dx: -x, box(width: W, height: peak, {
  place(bottom + left,  image("assets/footer-mountains-left.png",  width: W))
  place(bottom + right, image("assets/footer-mountains-right.png", height: peak))
  place(bottom + left, rect(width: W, height: peak, fill: gradient.linear(
    (bg, 0%), (bg, 30%), (bg.transparentize(100%), 100%), angle: 90deg)))
}))

// ---- shared pieces ----------------------------------------------------------
#let mono(s) = box(fill: code-bg, inset: (x: 3pt, y: 1pt), radius: 2pt,
  text(font: font-mono, size: 10.5pt, s))

#let bullet-list(items, gutter: 5mm) = grid(
  columns: (5mm, 1fr), column-gutter: 0mm, row-gutter: gutter,
  ..items.map(x => (text(fill: accent, weight: "bold")[•], x)).flatten()
)

#let head(title) = {
  accent-bar
  v(5mm)
  text(font: font-heading, size: fs-h2, weight: "bold", fill: ink, title)
  v(7mm)
}

// Footer: slide number on the left, the Serokell mark on the right - the mark
// sits in the same corner and at the same size as on the cover artwork.
#let deck-footer = context {
  let n = counter(page).get().first()
  grid(columns: (1fr, 1fr),
    align(left + horizon, text(font: font-body, size: 9pt, weight: "medium", fill: ink-soft, str(n))),
    align(right + horizon, box(image(mark-img, height: 5.6mm))))
}

// The single page primitive every layout builds on.
#let slide-raw(body, mtop: 16mm, mbot: 16mm, x: MX, tag: none, foot: true) = page(
  width: W, height: H, margin: (x: x, top: mtop, bottom: mbot), fill: bg,
  footer-descent: 7mm,
  footer: if foot { deck-footer } else { none },
  {
    // Module-level `set` rules do NOT cross the import boundary, so establish the
    // brand font, ink colour and leading here - every slide's body inherits them.
    set text(font: font-body, fill: ink, size: 14pt)
    set par(leading: 0.6em)
    if tag != none {
      place(top + right, text(font: font-mono, size: 8pt, fill: ink-soft.transparentize(45%))[#tag])
    }
    body
  },
)

// =============================================================================
// LAYOUTS
// =============================================================================

// 1. Cover - deck opener (bookend artwork, no footer).
#let cover(title, subtitle: none, meta: none, tag: none) = slide-raw(mtop: 26mm, mbot: 0mm, x: 20mm, tag: tag, foot: false, {
  accent-bar
  v(9mm)
  text(font: font-display, size: fs-hero, weight: "semibold", fill: ink)[#par(leading: 0.3em, justify: false, box(width: MEASURE, title))]
  if subtitle != none {
    v(6mm)
    text(font: font-heading, size: fs-lead, weight: "regular", fill: ink-soft)[#par(leading: 0.5em, justify: false, box(width: MEASURE, subtitle))]
  }
  if meta != none {
    v(5mm)
    text(font: font-body, size: fs-caption, fill: ink-soft, meta)
  }
  art-band(peak: 40mm, x: 20mm)
})

// 2. Section divider - big number + section title.
#let section(no, title, tag: none) = slide-raw(mtop: 34mm, tag: tag, {
  text(font: font-display, size: fs-mega, weight: "black", fill: accent,
    top-edge: "cap-height", bottom-edge: "baseline", no)
  v(9mm)
  text(font: font-heading, size: fs-h1, weight: "bold", fill: ink, title)
})

// 3. Statement - one big sentence.
#let statement(body, sub: none, tag: none) = slide-raw(mtop: 30mm, tag: tag, {
  accent-bar
  v(9mm)
  text(font: font-heading, size: fs-h1, weight: "bold", fill: ink)[#par(leading: 0.32em, justify: false, box(width: MEASURE, body))]
  if sub != none {
    v(7mm)
    text(font: font-body, size: fs-small, fill: ink-soft)[#par(leading: 0.5em, justify: false, box(width: MEASURE, sub))]
  }
})

// 4. Bullets - heading + list, with an optional lead line.
#let bullets(title, items, lead: none, tag: none) = slide-raw(tag: tag, {
  head(title)
  box(width: MEASURE, {
    if lead != none {
      text(size: fs-small, fill: ink-soft, lead)
      v(6mm)
    }
    set text(size: fs-body)
    bullet-list(items)
  })
})

// 5. Two columns of text.
#let two-col(title, left, right, tag: none) = slide-raw(tag: tag, {
  head(title)
  grid(columns: (1fr, 1fr), column-gutter: 12mm, align: top,
    text(size: fs-small, fill: ink, left),
    text(size: fs-small, fill: ink, right))
})

// 6. Split - text left, a visual panel right (image, or a labelled placeholder).
#let split(title, body, img: none, label: none, tag: none) = slide-raw(tag: tag, {
  head(title)
  // Centre the text + visual block in the space below the heading, so the image
  // reads as a balanced panel on the slide rather than hanging from the text top.
  v(1fr)
  grid(columns: (1fr, 96mm), column-gutter: 12mm, align: horizon,
    text(size: fs-small, fill: ink, body),
    box(width: 100%, height: 74mm, radius: 4pt, clip: true,
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
  v(1fr)
})

// 7. Stat - one huge accent number.
#let stat(number, caption, sub: none, tag: none) = slide-raw(mtop: 30mm, tag: tag, {
  accent-bar
  v(10mm)
  box(height: 26mm, align(bottom,
    text(font: font-display, size: fs-display, weight: "black", fill: accent, number)))
  v(9mm)
  text(font: font-heading, size: fs-h3, weight: "bold", fill: ink, caption)
  if sub != none {
    v(5mm)
    text(font: font-body, size: fs-small, fill: ink-soft, box(width: MEASURE, sub))
  }
})

// 8. Quote - pull quote with an accent spine.
#let quote-slide(body, who: none, tag: none) = slide-raw(mtop: 30mm, tag: tag, {
  block(stroke: (left: 3pt + accent), inset: (left: 10mm, y: 2mm), {
    text(font: font-heading, size: fs-quote, weight: "medium", fill: ink)[#par(leading: 0.36em, justify: false)[#box(width: MEASURE)[«#body»]]]
    if who != none {
      v(7mm)
      text(font: font-body, size: fs-small, weight: "semibold", fill: ink-soft, who)
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
    // Fixed height so every step box is the same size regardless of text length.
    cells.push(box(width: 100%, height: 46mm, fill: code-bg, radius: 4pt, stroke: (top: 2pt + accent), inset: (x: 11pt, y: 12pt), {
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

// 13. Closing - final statement over the artwork (bookend, no footer).
#let closing(body, sub: none, tag: none) = slide-raw(mtop: 30mm, mbot: 0mm, tag: tag, foot: false, {
  accent-bar
  v(9mm)
  text(font: font-heading, size: fs-h1, weight: "bold", fill: ink)[#par(leading: 0.32em, justify: false, box(width: MEASURE, body))]
  if sub != none {
    v(7mm)
    text(font: font-body, size: fs-small, fill: ink-soft)[#par(leading: 0.5em, justify: false, box(width: MEASURE, sub))]
  }
  art-band(peak: 42mm)
})
