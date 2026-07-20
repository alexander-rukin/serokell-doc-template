// =============================================================================
// Serokell document template - all branding lives here.
// Authors should not need to edit this file; they only write Markdown.
// =============================================================================

// ---------------------------------------------------------------- design tokens

#let accent = rgb("#D92B04")
#let ink = rgb("#1A1A1A") // body text
#let ink-soft = rgb("#5A5F66") // captions, page numbers, table rules
#let hairline = rgb("#DDE1E5") // table / block borders
#let code-bg = rgb("#F5F6F7")

// Google Sans Flex ships as per-optical-size families. Picking the family
// chooses the optical size; `weight` chooses the cut.
#let font-display = "Google Sans Flex 120pt" // cover title only
#let font-heading = "Google Sans Flex 36pt" // h1-h3
#let font-body = "Google Sans Flex 24pt" // body copy
#let font-mono = "JetBrains Mono" // code

#let size-body = 10.5pt
#let leading-body = 0.72em

// Cover title. Anything from "medium" to "black" is available in
// assets/fonts - dial the weight here rather than in the cover function.
#let title-size = 40pt
#let title-weight = "semibold"

// How wide a Markdown table is drawn. Two modes:
//   "auto" - columns are sized to their contents, so a narrow table occupies
//            only part of the text width and sits to the left.
//   "full" - columns share the text width equally, so every table spans the
//            full measure regardless of how little is in it.
// A document can override this from its frontmatter with `tables: full`.
#let table-width = "auto"

#let page-margin = (top: 24mm, bottom: 40mm, x: 20mm)
#let page-width = 210mm // A4

// ---------------------------------------------------------------- artwork
//
// The mountains are drawn at ONE size everywhere: full page width, peak at
// `art-peak-height`. Content pages do not get a shrunken copy - they get the
// same composition, dissolved into the page from the top.
//
// How the dissolve works, because it is easy to get backwards: a white
// gradient is painted ON TOP of the photo, opaque white at the top fading to
// fully clear at the bottom. The photo itself is never made transparent. That
// keeps the mountain solid where it meets the trim edge (nothing shows through
// it) and removes the hard horizontal cut at its top edge, so the artwork
// fades out like cloud rather than ending in a line.
//
// Making the image itself semi-transparent instead would let the page show
// through the rock, which reads as a mistake.

#let art-peak-height = 92mm

// Where the white veil stops being fully opaque. Below this fraction of the
// artwork the mountain starts becoming visible; above it the artwork is gone.
// Raise it to push the mountain further down the page.
#let art-fade-start = 38%

// Vertical centre of the Serokell mark baked into the peak image, as a fraction
// of that image's height measured from its top. Taken from the source PNG: the
// glyph occupies rows 773..835 of 940. The page number is aligned to the same
// line, so the two read as one row across the foot of the page. Re-measure this
// if footer-mountains-right.png is ever replaced.
#let art-logo-centre = 0.8553
#let footer-baseline = art-peak-height * (1.0 - art-logo-centre)

#let mountains(peak-height: art-peak-height) = {
  box(width: page-width, height: peak-height, {
    // Left: pale range across the full page width, sitting on the baseline.
    place(bottom + left, image("assets/footer-mountains-left.png", width: page-width))
    // Right: high-contrast peak, carrying the Serokell mark, drawn on top.
    place(bottom + right, image("assets/footer-mountains-right.png", height: peak-height))
  })
}

// Content-page backdrop: the same mountains, veiled from the top.
// Used as `page(background:)` so it sits behind the body text.
#let backdrop(has-art: true) = {
  if not has-art { return none }

  place(bottom + left, box(width: page-width, height: art-peak-height, {
    mountains()
    // 90deg runs the gradient top -> bottom.
    place(bottom + left, rect(
      width: page-width,
      height: art-peak-height,
      fill: gradient.linear(
        (white, 0%),
        (white, art-fade-start),
        (white.transparentize(100%), 100%),
        angle: 90deg,
      ),
    ))
  }))
}

// ---------------------------------------------------------------- footer

// Page number only, inside the footer, left-hand side. The artwork is no longer
// footer content - it is the page background - so the footer stays a thin strip
// and the number sits in it rather than floating above a band.
#let make-footer(has-art: true) = context {
  let n = counter(page).get().first()
  // Page 1 is the cover - no footer chrome there.
  if n <= 1 { return }

  // The number is centred on `footer-baseline`, the same line the Serokell mark
  // sits on inside the artwork. A fixed-height box centred with `horizon` keeps
  // that true regardless of the number's own font size.
  let slug = 6mm

  box(width: 100%, height: page-margin.bottom, {
    place(
      bottom + left,
      dy: -(footer-baseline - slug / 2),
      box(height: slug, align(horizon, text(
        font: font-body,
        size: 8.5pt,
        weight: "medium",
        fill: ink-soft,
        str(n),
      ))),
    )
    if not has-art {
      // Keeps the layout honest when assets/ is not populated.
      place(top + left, line(length: 100%, stroke: 0.6pt + hairline))
    }
  })
}

// ---------------------------------------------------------------- cover page

#let cover(title: none, subtitle: none, author: none, date: none, has-art: true) = {
  // background: none - the cover paints its own artwork at full strength, and
  // must not also inherit the veiled content-page backdrop.
  page(
    margin: (top: 34mm, bottom: 0mm, x: 20mm),
    footer: none,
    header: none,
    background: none,
    {
    // Accent rule as the brand anchor at the top of the cover.
    box(width: 18mm, height: 3.5pt, fill: accent)
    v(10mm)

    text(
      font: font-display,
      size: title-size,
      weight: title-weight,
      fill: ink,
      hyphenate: false,
      // justify: false, or the body text's justification stretches a short
      // first line of the title across the full measure.
    )[#par(leading: 0.28em, justify: false, title)]

    if subtitle != none {
      v(5mm)
      text(font: font-heading, size: 15pt, weight: "regular", fill: ink-soft)[
        #par(leading: 0.5em, justify: false, subtitle)
      ]
    }

    v(8mm)

    // Author / date, set as a quiet two-line block.
    text(font: font-body, size: 10pt, fill: ink, {
      if author != none {
        text(weight: "semibold", author)
        linebreak()
      }
      if date != none {
        text(fill: ink-soft, date)
      }
    })

    // Push the artwork to the bottom edge of the cover, at full strength.
    place(bottom + left, dx: -page-margin.x, {
      if has-art {
        mountains()
      } else {
        box(width: page-width, height: art-peak-height, place(
          bottom + left,
          line(length: 100%, stroke: 0.6pt + hairline),
        ))
      }
    })
    },
  )
}

// ---------------------------------------------------------------- md tables

// Shared so the two width modes are styled identically.
#let table-stroke = (x, y) => (
  top: if y == 0 { 0pt } else if y == 1 { 1pt + ink } else { 0.5pt + hairline },
  bottom: 0pt,
  left: 0pt,
  right: 0pt,
)

// Gutter between columns, but the outer edges stay flush with the margins.
#let table-inset = (x, y) => (
  left: if x == 0 { 0pt } else { 6mm },
  right: 0pt,
  top: 7pt,
  bottom: 7pt,
)

// Redraw a Markdown table with fractional columns so it fills the text width.
//
// This has to produce a `grid`, not a `table`, for two reasons:
//   * a `set table(columns: ..)` rule cannot win, because cmarker passes
//     `columns` explicitly when it builds the element;
//   * a `show table` rule that returns a new `table` matches its own output and
//     recurses until Typst gives up.
// A grid takes the same stroke and inset API, so the result is identical apart
// from the column widths.
//
// Overriding cmarker's `table` through its `scope` looks tempting and does not
// work: cmarker also resolves `table.cell` and `table.header` against that same
// name, and a user-defined function has no fields.
#let stretch-table(it) = {
  let n = if type(it.columns) == int { it.columns } else { it.columns.len() }

  let convert(c, header: false) = {
    let body = if header {
      text(font: font-heading, weight: "semibold", size: 9.5pt, c.body)
    } else {
      c.body
    }
    let extra = (:)
    let cs = c.at("colspan", default: 1)
    if cs != 1 { extra.insert("colspan", cs) }
    let rs = c.at("rowspan", default: 1)
    if rs != 1 { extra.insert("rowspan", rs) }
    grid.cell(..extra, body)
  }

  let kids = ()
  for c in it.children {
    if c.func() == table.header {
      kids.push(grid.header(..c.children.map(x => convert(x, header: true))))
    } else if c.func() == table.footer {
      kids.push(grid.footer(..c.children.map(convert)))
    } else {
      kids.push(convert(c))
    }
  }

  // Column alignment from the Markdown colons lives on the table element's
  // `align` field as an array like (left, center, right), NOT on the cells -
  // the cells carry nothing but their body. Forgetting to carry this over
  // silently left-aligns every column.
  grid(
    columns: (1fr,) * n,
    align: it.at("align", default: auto),
    stroke: table-stroke,
    inset: table-inset,
    ..kids,
  )
}

// ---------------------------------------------------------------- main show rule

#let report(
  title: "Untitled",
  subtitle: none,
  author: none,
  date: none,
  has-art: true,
  tables: table-width,
  body,
) = {
  set document(title: title, author: if author == none { () } else { author })

  set page(
    paper: "a4",
    margin: page-margin,
    footer: make-footer(has-art: has-art),
    // 0mm so the footer box starts exactly at the top of the bottom margin.
    footer-descent: 0mm,
    background: backdrop(has-art: has-art),
  )

  set text(font: font-body, size: size-body, fill: ink, lang: "en")
  set par(justify: true, leading: leading-body, spacing: 1.15em)

  // --- headings -------------------------------------------------------------
  show heading: set text(font: font-heading, fill: ink, hyphenate: false)

  show heading.where(level: 1): it => {
    v(9mm, weak: true)
    block(text(size: 20pt, weight: "bold", it.body))
    v(4mm, weak: true)
  }

  show heading.where(level: 2): it => {
    v(7mm, weak: true)
    block(text(size: 14pt, weight: "semibold", it.body))
    v(2.5mm, weak: true)
  }

  show heading.where(level: 3): it => {
    v(5mm, weak: true)
    block(text(size: 11.5pt, weight: "semibold", fill: ink-soft, it.body))
    v(1.5mm, weak: true)
  }

  // --- links ----------------------------------------------------------------
  show link: it => text(fill: accent, it)

  // --- code -----------------------------------------------------------------
  show raw: set text(font: font-mono, size: 9pt)
  // Inline code: subtle tint, no border.
  show raw.where(block: false): it => box(
    fill: code-bg,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
    it,
  )
  // Block code: tinted panel with an accent spine on the left.
  // NOTE: the body must be a content block with a `set par`, not a `par(..)`
  // call. Wrapping raw in an explicit `par` makes Typst treat the code as
  // block-level content inside a paragraph and silently drop it.
  show raw.where(block: true): it => block(
    width: 100%,
    fill: code-bg,
    stroke: (left: 2pt + accent),
    radius: (right: 3pt),
    inset: (x: 10pt, y: 9pt),
    {
      set par(justify: false, leading: 0.6em)
      it
    },
  )

  // --- tables ---------------------------------------------------------------
  // Clean and rule-light: a heavy line under the header, hairlines between rows.
  set table(stroke: table-stroke, inset: table-inset, fill: none)
  show table.cell.where(y: 0): set text(
    font: font-heading,
    weight: "semibold",
    size: 9.5pt,
  )
  show table: set par(justify: false)
  show table: set text(size: 9.5pt)

  // In "full" mode the table is rebuilt as a grid with fractional columns.
  // See `stretch-table` for why it has to be a grid and not a table.
  show table: it => if tables == "full" { stretch-table(it) } else { it }

  // --- quotes ---------------------------------------------------------------
  set quote(block: true)
  show quote: it => block(
    width: 100%,
    inset: (left: 9mm, right: 4mm, y: 1mm),
    stroke: (left: 2.5pt + accent),
    text(size: 10.5pt, fill: ink-soft, style: "italic", it.body),
  )

  // --- lists ----------------------------------------------------------------
  set list(marker: text(fill: accent, weight: "bold")[•], indent: 3mm, spacing: 0.9em)
  set enum(indent: 3mm, spacing: 0.9em, numbering: n => text(
    fill: accent,
    weight: "semibold",
    [#n.],
  ))

  // --- figures --------------------------------------------------------------
  show figure.caption: set text(size: 8.5pt, fill: ink-soft)
  // NOTE: deliberately no `set image(width: 100%)` here. A global image set
  // rule also hits the cover and footer artwork and, combined with their
  // explicit `height`, stretches them out of aspect. Body images are sized in
  // main.typ, scoped to the rendered Markdown only.

  // --- rules ----------------------------------------------------------------
  show line: set line(stroke: 0.6pt + hairline)

  cover(
    title: title,
    subtitle: subtitle,
    author: author,
    date: date,
    has-art: has-art,
  )

  counter(page).update(2)
  body
}

// ---------------------------------------------------------------- frontmatter

// Minimal YAML-ish frontmatter reader so authors can put title/author/date at
// the top of their .md and never touch Typst. Supports `key: value` lines and
// optional surrounding quotes.
#let split-frontmatter(src) = {
  let m = src.match(regex("(?s)^---\r?\n(.*?)\r?\n---\r?\n?"))
  if m == none { return ((:), src) }

  let meta = (:)
  for line in m.captures.first().split("\n") {
    let line = line.trim()
    if line == "" or line.starts-with("#") { continue }
    let parts = line.split(":")
    if parts.len() < 2 { continue }
    let key = parts.first().trim()
    let value = parts.slice(1).join(":").trim()
    // strip matching surrounding quotes
    if value.len() >= 2 and (
      (value.starts-with("\"") and value.ends-with("\""))
        or (value.starts-with("'") and value.ends-with("'"))
    ) {
      value = value.slice(1, -1)
    }
    meta.insert(key, value)
  }
  (meta, src.slice(m.end))
}
