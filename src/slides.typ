// =============================================================================
// Serokell slide system - layouts lifted 1:1 from the "Light Slides" template.
//
// Everything here - margins, exact element coordinates, type scale, the rounded
// grey cards, the "heading sits at a fixed left band, content to the right"
// language, the deep whitespace - is reproduced from the template. The ONLY
// thing that is ours is the typeface (Google Sans Flex optical, Cyrillic via a
// bundled Golos Text fallback). No red, no logo, no mountains: the template has
// none of those.
//
// Theme:  compile with  --input theme=dark  (default light).
// Usage:  #import "slides.typ": *  then one call per slide, in order.
// =============================================================================

#let theme = sys.inputs.at("theme", default: "light")
#let dark  = theme == "dark"

// ---- tokens (template: pure black / white / grey) ---------------------------
#let bg       = if dark { rgb("#2A282E") } else { white }
#let ink      = if dark { rgb("#F3F4F6") } else { rgb("#000000") }
#let ink-soft = if dark { rgb("#9AA0A6") } else { rgb("#404040") }
// soft, clean card: a very light fill with a hairline border, not a muddy
// mid-grey, which read as dirty. The border keeps the near-white light card
// legible against the white page.
#let card-bg     = if dark { rgb("#37363D") } else { rgb("#F1F1F3") }
#let card-stroke = if dark { 0.75pt + rgb("#494851") } else { 0.75pt + rgb("#E2E2E6") }
#let card-ink = if dark { rgb("#F3F4F6") } else { rgb("#000000") }
#let code-bg  = if dark { rgb("#34333A") } else { rgb("#F0F0F0") }
// brand shell that lives OUTSIDE the template grid (cover art + corner furniture)
#let accent   = rgb("#D92B04")
#let mark-img = if dark { "/assets/serokell-mark-light.svg" } else { "/assets/serokell-mark-dark.svg" }

// ---- fonts (ours - the one thing kept from our brand) -----------------------
#let font-emoji   = "Noto Color Emoji"
#let font-display = ("Google Sans Flex 120pt", "Golos Text", font-emoji)
#let font-heading = ("Google Sans Flex 36pt", "Golos Text", font-emoji)
#let font-body    = ("Google Sans Flex 24pt", "Golos Text", font-emoji)
#let font-mono    = ("JetBrains Mono", "Golos Text", font-emoji)

// ---- geometry & type scale (exact template values) --------------------------
#let W  = 254mm
#let H  = 142.875mm
#let M  = 16.9mm         // uniform frame inset, all four sides
#let CW = W - 2 * M

// Modular scale: ONE ratio (1.25, major third) off a 12pt body. Every role is
// base * 1.25^n, so steps relate cleanly instead of drifting per-role (sizes
// felt random because the old ratio wandered between 1.20 and 1.60).
#let fs-title = 36.6pt   // display hero   (step +5)  cover/section/statement/stat/closing
#let fs-lead2 = 23.4pt   // metric number  (step +3)  step numbers, highlight
#let fs-head  = 18.8pt   // working heading (step +2) content-slide heading, card statement
#let fs-item  = 15pt     // subhead / label (step +1) subtitle, item, card label
#let fs-desc  = 12pt     // body            (step  0)  description, running text
#let fs-small = 9.6pt    // caption         (step -1)  caption, attribution, meta, axis

#let card-r = 3mm        // rounded card corners (template)

// ---- spacing & measure tokens (ONE rhythm across all layouts) ---------------
// Vertical rhythm RULE: the gap below a text element scales with the size of
// THAT element (a fixed em-fraction of it), so big type gets proportionally
// more air than small type, and the same role-pair gets the same gap on every
// slide. No per-layout magic millimetres.
// The gap under a heading GROWS with the heading's size, so the three levels are
// visibly different air, not the same 4.5mm under every title (slides
// 5 and 6 had identical gaps under differently-sized headings).
#let gap-hero-sub   = 0.65 * fs-title  // ~8.4mm  H1 display hero -> sub / attribution
                                       //         (cover, statement, stat, quote, closing)
#let gap-head-body  = 1.05 * fs-head   // ~7.0mm  H2 heading -> body / subhead / lead
                                       //         (bullets, split, matrix, cards lead, code)
#let gap-label-body = 0.90 * fs-item   // ~4.8mm  H3 label -> its body INSIDE a card
                                       //         (card label; the frame lets it breathe)
#let gap-label-tight = 0.45 * fs-item  // ~2.4mm  H3 label -> its body on the OPEN page
                                       //         (two-col: label + body must read as ONE
                                       //         block, not two spaced elements)
#let gap-fig-label  = 0.75 * fs-lead2   // ~6.2mm  BIG figure -> its label/description;
                                       //         tied to the figure's own kegel, so a big
                                       //         number gets more air than a text label.
                                       //         Same on EVERY metric slide (kpis, metric-cols,
                                       //         metric-grid).
#let gap-num-body   = 0.60 * fs-lead2  // ~5mm    step number -> step text
#let gap-meta       = 0.90 * fs-item   // ~4.8mm  sub -> small muted meta line: meta
                                       //         is a SEPARATE service line, not a tail
                                       //         of the subtitle - needs real air
#let gap-item       = 9mm  // list rhythm (bullets)
#let Y2      = 45          // content band top (mm) for heading-top layouts
#let colw    = 95          // text column measure (mm): bullets, two-col, split, matrix
#let bigw    = 205         // display-statement measure (mm): cover, section, stat, quote
#let gut-card = 6.4        // gutter between cards in a row (mm) - ONE value for every
                          // card row (compare, cards, steps), independent of count:
                          // 4-up must not gap wider than 3-up.
// Leading per role: display tightens with size, but a multi-line H1 still needs air
// between its lines - 0.28em felt cramped in two lines.
#let lead-disp = 0.36em    // multi-line display titles
#let lead-head = 0.5em     // fs-head bold blocks (quote, card statement)
#let fs-code   = 11pt      // mono code on the code slide (denser than body)

// ---- brand corner furniture (sits in the bottom margin, LOW - 9mm off edge) --
// The template's content grid uses a 16.9mm margin, but our footer chrome lives
// below that, close to the physical bottom edge like the doc template's footer.
#let BOT = 6mm
#let FOOT_DROP = M - BOT   // push furniture from the content box down into margin
#let bar-w = 16mm
#let bar-h = 3pt
#let accent-bar = box(width: bar-w, height: bar-h, fill: accent)
#let logo-box = box(image(mark-img, height: 5mm))
#let deck-num = context box(height: 5mm, align(horizon,
  text(font: font-body, size: 10pt, weight: "medium", fill: ink,
    str(counter(page).get().first()))))

// ---- base text --------------------------------------------------------------
#set text(font: font-body, size: fs-desc, fill: ink, lang: "ru")
#set par(leading: 0.6em)

// ---- absolute placement: put a box of width `w` mm at template coords (x,y) --
// The page margin is M on every side, so place(top+left) origin is (M,M); shift
// by (x-M, y-M) to land at the template's absolute millimetre coordinate.
#let at(x, y, w, body) = place(top + left, dx: x * 1mm - M, dy: y * 1mm - M,
  box(width: w * 1mm, body))

// vertically-centred block on the left band (x=16.9). Single-content layouts
// (statement, stat, quote, section, closing) and the text half of side-by-side
// layouts all sit on the frame's vertical midline, so nothing floats at an
// unrelated height. x-offset can be overridden for the right col.
#let vblock(w, body, x: 16.9) = place(horizon + left, dx: x * 1mm - M,
  box(width: w * 1mm, body))

// text helpers (weight/font per role, all template-black)
// top-edge/bottom-edge trim the display faces' tall optical line-box to the real
// glyph extent (cap-height..baseline), so a heading doesn't leave a big air gap
// below it before the next element.
#let disp(s, body) = text(font: font-display, size: s, weight: "bold", fill: ink,
  top-edge: "cap-height", bottom-edge: "baseline", body)
#let hd(s, body)   = text(font: font-heading, size: s, weight: "bold", fill: ink,
  top-edge: "cap-height", bottom-edge: "baseline", body)
#let bd(s, body, fill: ink) = text(font: font-body, size: s, fill: fill, body)

// ---- the fixed hierarchy (see typescale specimen) - one role per job ---------
// Three roles share the 15pt step but separate by WEIGHT so no two thin levels
// ever sit together:
//  lbl  - H3 Label 15 Bold   : card / column label, pairs with Body below it.
//  subh - Subhead 15 Medium : the ONE explanatory line under H1/H2. Medium,
//         not Regular, so it holds against Body's Regular.
//  cap  - Caption 9.6 Regular muted : footnote, attribution, meta, axis label.
#let lbl(body, fill: card-ink) = text(font: font-heading, size: fs-item,
  weight: "bold", fill: fill, body)
#let subh(body, fill: ink) = text(font: font-body, size: fs-item,
  weight: "medium", fill: fill, body)
#let cap(body) = text(font: font-body, size: fs-small, fill: ink-soft, body)
//  note - Body 12 Regular muted : an explanatory SENTENCE attached to content
//         (a code caption, a roadmap stage). Caption size is for things that are
//         not sentences - meta, attribution, a role, an axis label. A sentence
//         that carries meaning is body size, just quieter.
#let note(body) = text(font: font-body, size: fs-desc, fill: ink-soft, body)

// ---- brand accents (the ONE colour we add: red #D92B04) ---------------------
// Deliberately sparse - one accent per slide, never more. Overuse kills it.
//  ac[word]  : paint ONE key word the brand red AND bold it. In a heading the text
//              is already bold so it just reddens; in running text the accent word
//              also gains weight so it holds up against the red.
//  noted[..] : a chunky red vertical rule down the left edge of a small note or
//              caption, echoing the cover's accent bar. ONLY for footnotes / small
//              remarks - NOT for headings or pull quotes (looked odd).
#let ac(body) = text(weight: "bold", fill: accent, body)
// thin red rule that stands TALLER than the note text and runs down its left,
// vertically centred on the text (longer, not thicker).
#let noted(body) = grid(columns: (2.4pt, auto), column-gutter: 5mm, align: horizon,
  box(width: 2.4pt, height: 7mm, fill: accent), body)

// a soft rounded card: label (H3) and body (Body) as ONE group at the top, with
// the label->body gap between them. Previously the label was pinned to the top and
// a big bold statement to the bottom, leaving a dead hole in the middle and reading
// as heavy all-caps. Now: light card, hairline border,
// label bold, body regular - grouped, breathing, no floor-pin.
#let gcard(x, y, w, h, label, statement) = at(x, y, w, box(
  width: 100%, height: h * 1mm, radius: card-r, fill: card-bg, stroke: card-stroke,
  inset: 6.5mm,
  {
    lbl(label)
    v(gap-label-body)
    text(size: fs-desc, fill: card-ink, par(leading: 0.6em, statement))
  }))

// the single page primitive. Content sits on the template's 16.9mm grid; the
// brand footer (mark bottom-right + page number bottom-left) sits LOW in the
// bottom margin. Cover passes foot:false (it carries its own white mark on art).
#let slide-raw(body, tag: none, foot: true, num: true) = page(
  width: W, height: H, margin: M, fill: bg, {
  set text(font: font-body, fill: ink, size: fs-desc)
  // leading = within-paragraph line gap; spacing = BETWEEN paragraphs. In Typst
  // 0.15 block(spacing) does NOT zero paragraph spacing - it defaults to ~1.2em,
  // which is the oversized gap between a heading and its sub-line. Zero it;
  // every layout controls its own gaps with explicit v().
  set par(leading: 0.6em, spacing: 0pt)
  set block(spacing: 0pt)
  body
  if foot {
    place(bottom + right, dy: FOOT_DROP, logo-box)
    if num { place(bottom + left, dy: FOOT_DROP, deck-num) }
  }
})

// =============================================================================
// LAYOUTS  (one per template archetype)
// =============================================================================

// Cover - template title placement (left, y=59) PLUS our brand shell: the
// mountain range band + a mirrored peak on the right + white Serokell mark +
// the red accent tick. Mountains are part of the brand and stay.
#let cover(title, subtitle: none, meta: none, tag: none) = slide-raw(tag: tag, foot: false, {
  // single full-width mountain footer (one cohesive band, fades into the white
  // page at the top; tall peak on the right). Replaces the band + mirrored peak.
  place(bottom + left, dx: -M, dy: M,
    image("/assets/brand-footer-long.png", width: W))
  // Mark in the same bottom-right footer spot as every other slide (white so it
  // reads on the peak) - consistent logo position across the whole deck.
  place(bottom + right, dy: FOOT_DROP, box(image("/assets/serokell-mark-light.svg", height: 5mm)))
  // accent tick pinned to the TOP-LEFT of the content grid, not floating by the
  // title - reads as a brand marker on the frame, not a heading underline
  place(top + left, accent-bar)
  // title block on the lower-left band: TWO text roles only (title + subtitle).
  // The meta line moves down to the footer slot (below), so the block doesn't
  // stack three type sizes.
  // meta lives INSIDE the text block, a plain small line under the subtitle -
  // NOT in the bottom furniture zone, where it crossed the mountain art on dark
  // and hung detached on light.
  at(16.9, 55, bigw, {
    disp(fs-title, par(leading: lead-disp, title))
    if subtitle != none { v(gap-hero-sub); subh(subtitle) }
    if meta != none { v(gap-meta); cap(meta) }
  })
})

// eyebrow / kicker - a small bold label that sits ABOVE a title (the template's
// "Subtitle" over "Header" pattern). Same face/size as a card label (H3), full
// ink, tight gap to the title below so the two read as one titled unit.
#let kick(body, fill: ink) = text(font: font-heading, size: fs-item,
  weight: "bold", fill: fill, body)

// Section divider (template slide 2): the section title alone as the hero on the
// left band. Optional kicker (eyebrow) above it. No section number, and NO accent
// bar - the red bar is reserved for the COVER only, so it reads as "the deck
// starts here", not a repeating mark: the bar belongs on the cover only.
#let section(title, kicker: none, tag: none) = slide-raw(tag: tag, {
  vblock(bigw, {
    if kicker != none { kick(kicker); v(gap-label-tight) }
    disp(fs-title, par(leading: lead-disp, title))
  })
})

// Statement / section-with-description (template slide 3). Optional kicker above.
#let statement(body, sub: none, kicker: none, tag: none) = slide-raw(tag: tag, {
  vblock(bigw, {
    if kicker != none { kick(kicker); v(gap-label-tight) }
    disp(fs-title, par(leading: lead-disp, body))
    if sub != none { v(gap-hero-sub); subh(sub) }
  })
})

// Bullets -> "Simple list" (template slide 7): heading at the left band (y=67.6),
// items stacked in the right column (x=128.1). Optional lead under the heading.
#let bullets(title, items, lead: none, tag: none) = slide-raw(tag: tag, {
  // Heading (left band) and the item stack (right column) share ONE vertical
  // centre, so the two read as a paired "heading | list", not two blocks floating
  // at unrelated heights.
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, title)
    // lead is the subhead under H2 (15 Medium), so it is NOT smaller than the
    // items on the right (the subhead was 12, the items were 15).
    if lead != none { v(gap-head-body); subh(lead) }
  }))
  // Each item is EITHER a bare line (str) OR a (heading, text) mini-block that
  // reads like the card slides - a bold label + a supporting line. Blocks get
  // a bigger inter-item gap (they are two lines each); bare lines keep gap-item.
  place(horizon + left, dx: 128.1mm - M, box(width: colw * 1mm, {
    for (i, it) in items.enumerate() {
      let block = type(it) == array
      // between blocks: clearly bigger than the heading->text gap inside a block,
      // so each mini-card reads as one unit.
      if i > 0 { v(if block { 11mm } else { gap-item }) }
      if block {
        // EXACTLY the card's heading->text piece: lbl + gap-label-body + bd. Same
        // token as cards/two-col so the distance matches everywhere.
        lbl(it.at(0), fill: ink)
        v(gap-label-body)
        bd(fs-desc, it.at(1))
      } else {
        bd(fs-desc, it)
      }
    }
  }))
})

// Two columns (template slide 8/9): heading top-left, two text columns below.
// Each column is a (heading, body) pair: bold heading on its own line, body below.
// NOT heading+body as one paragraph.
#let two-col(title, left, right, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  // ONE label->body gap for every open-page label+body pair in the deck
  // (columns, two-col, feature-grid, image-row, metric rows): gap-label-body,
  // the same gap the cards use. The old split (tight 2.4mm
  // in columns vs a doubled ~6.7mm here from an extra par-spacing) read as
  // inconsistent with no discernible rule. No stray par-spacing.
  let col(x, pair) = at(x, Y2, colw, {
    lbl(pair.at(0), fill: ink)
    v(gap-label-body)
    bd(fs-desc, par(leading: 0.6em, pair.at(1)))
  })
  col(16.9, left)
  col(128.1, right)
})

// Split - text left, image right (template image + description). Optional kicker
// above the heading. `bleed: true` runs the image edge-to-edge on the right (full
// slide height, flush to the right and top/bottom edges - template slide 14).
#let split(title, body, img: none, label: none, kicker: none, bleed: false, tag: none) = slide-raw(tag: tag, {
  vblock(colw, {
    if kicker != none { kick(kicker); v(gap-label-tight) }
    hd(fs-head, title)
    v(gap-head-body)
    set par(spacing: 0.9em)   // multi-paragraph body separates (global spacing is 0)
    bd(fs-desc, body)
  })
  if bleed {
    // edge-to-edge column on the right half: from the horizontal midway point to
    // the physical right edge, full page height (ignores the frame margin).
    place(top + left, dx: 132 * 1mm - M, dy: -M,
      box(width: W - 132mm, height: H, clip: true,
        fill: if img == none { card-bg } else { none },
        if img != none { image(img, width: 100%, height: 100%, fit: "cover") }
        else { place(center + horizon, subh(if label != none { label } else { [visual] }, fill: card-ink)) }))
  } else {
    place(top + left, dx: 128.1 * 1mm - M, dy: 16.9 * 1mm - M,
      box(width: 109mm, height: 109mm, radius: card-r, clip: true,
        fill: if img == none { card-bg } else { none },
        stroke: if img == none { card-stroke } else { none },
        if img != none { image(img, width: 100%, height: 100%, fit: "cover") }
        else { place(center + horizon, subh(if label != none { label } else { [visual] }, fill: card-ink)) }))
  }
})

// Stat - one big figure (template big-stat): number left at y=59, caption + sub.
#let stat(number, caption, sub: none, tag: none) = slide-raw(tag: tag, {
  vblock(bigw, {
    disp(fs-title, number)
    v(gap-hero-sub)
    // subhead under a display hero: the single Subhead role (15 Medium),
    // same as statement's sub.
    subh(caption)
    if sub != none { v(gap-meta); cap(sub) }
  })
})

// Quote (template quote): left-aligned pull quote + attribution, in the left band.
#let quote-slide(body, who: none, tag: none) = slide-raw(tag: tag, {
  vblock(bigw, {
    // closing period sits OUTSIDE the guillemets, the Russian norm;
    // pass `body` WITHOUT a trailing period.
    hd(fs-head, par(leading: lead-head)[«#body».])
    // attribution is NOT a tiny caption under an H2 - that is banned. It is a muted Subhead (15 Medium).
    // gap is tied to fs-head (the quote's size), NOT gap-hero-sub (tied to the
    // bigger fs-title) - that read too wide here.
    if who != none {
      v(gap-head-body)
      text(font: font-body, size: fs-item, weight: "medium", fill: ink-soft, who)
    }
  })
})

// Compare -> two rounded grey cards (template principles), heading top-left.
#let compare(title, a-head, a-body, b-head, b-body, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  // two cards fill the content width exactly: right edge lands on the frame's
  // right margin (was 1mm past it), bottom on the content floor (was 1mm past).
  let w = (CW / 1mm - gut-card) / 2
  let h = 125.975 - Y2
  gcard(16.9, Y2, w, h, a-head, a-body)
  gcard(16.9 + w + gut-card, Y2, w, h, b-head, b-body)
})

// Code - neutral mono block, heading top-left (template has no code slide).
#let code-slide(title, code, caption: none, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  // caption flows right under the code block (fixed y left a dead hole between
  // a short snippet and a caption pinned to the page bottom).
  at(16.9, Y2, CW / 1mm, {
    block(width: 100%, fill: code-bg, radius: card-r, inset: 12pt,
      text(font: font-mono, size: fs-code, fill: ink, code))
    if caption != none { v(gap-head-body); note(caption) }
  })
})

// Steps - a row of tall step CARDS filling the content band (like compare):
// each step is a rounded card with the number prominent at the top and the
// step text below it. Bare numbers next to text didn't read as steps at all.
#let steps(title, items, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  let n = items.len()
  let w = (CW / 1mm - gut-card * (n - 1)) / n
  // step cards are sized to their content (number + a short line), not stretched
  // to the whole content floor - the full-height version left a dead hole under
  // the text. Fixed height, vertically centred in the content band.
  let h = 62
  let cy = Y2 + (125.975 - Y2 - h) / 2
  for (i, it) in items.enumerate() {
    at(16.9 + i * (w + gut-card), cy, w, box(
      width: 100%, height: h * 1mm, radius: card-r, fill: card-bg,
      stroke: card-stroke, inset: 6.5mm,
      {
        disp(fs-lead2, text(fill: card-ink, str(i + 1)))
        v(gap-num-body)
        text(size: fs-desc, fill: card-ink, par(leading: 0.6em, it))
      }))
  }
})

// Cards - a row of rounded grey cards (template): heading top + lead, label + desc.
#let cards(title, items, lead: none, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, {
    hd(fs-head, title)
    if lead != none { v(gap-head-body); bd(fs-desc, lead) }
  })
  let n = items.len()
  let w = (CW / 1mm - gut-card * (n - 1)) / n
  for (i, it) in items.enumerate() {
    at(16.9 + i * (w + gut-card), Y2, w, box(
      width: 100%, height: 62mm, radius: card-r, fill: card-bg,
      stroke: card-stroke, inset: 6.5mm,
      {
        lbl(it.at(0))
        v(gap-label-body)
        text(size: fs-desc, fill: card-ink, par(leading: 0.6em, it.at(1)))
      }))
  }
})

// Closing - final statement, minimal, left (template style: like the cover).
#let closing(body, sub: none, tag: none) = slide-raw(tag: tag, {
  vblock(bigw, {
    disp(fs-title, par(leading: lead-disp, body))
    if sub != none { v(gap-hero-sub); subh(sub) }
  })
})

// Matrix 2x2 (template slide 24): heading + description on the left band, a cross
// with two axes and four labelled grey bubbles on the right. Bubble labels flow
// with our font - short labels sit on one line; the bubble is sized for them, so
// nothing shatters into "La/bel" the way the fixed-metric template did.
#let matrix2x2(title, desc, x-axis, y-axis, quads, tag: none) = slide-raw(tag: tag, {
  vblock(colw, {
    hd(fs-head, title)
    v(gap-head-body)
    subh(desc)
  })
  // cross centre on the right half
  let cx = 176.0        // mm
  let cy = 71.4         // mm (vertical middle of the frame)
  // arm length keeps every axis LABEL inside the 16.9mm frame: with 58 the top
  // label sat in the top margin, the bottom one collided with the footer and
  // a one-word label ran past the right margin. 46 still clears the bubbles (offset 30
  // + r15 = 45).
  let ax = 46.0         // half-length of each axis arm, mm
  let d  = 30.0         // bubble diameter, mm
  let off = 30.0        // quadrant centre offset from cross, mm
  // axes (thin ink lines)
  place(top + left, dx: (cx - ax) * 1mm - M, dy: cy * 1mm - M,
    box(width: (2 * ax) * 1mm, height: 1.1pt, fill: ink))
  place(top + left, dx: cx * 1mm - M, dy: (cy - ax) * 1mm - M,
    box(width: 1.1pt, height: (2 * ax) * 1mm, fill: ink))
  // axis end labels
  at(cx - 30, cy - ax - 6.5, 60, align(center, bd(fs-small, y-axis.at(0), fill: ink-soft)))
  at(cx - 30, cy + ax + 2.5, 60, align(center, bd(fs-small, y-axis.at(1), fill: ink-soft)))
  at(cx + ax + 2.5, cy - 2.5, 40, bd(fs-small, x-axis.at(1), fill: ink-soft))
  at(cx - ax - 42.5, cy - 2.5, 40, align(right, bd(fs-small, x-axis.at(0), fill: ink-soft)))
  // four bubbles at quadrant centres: order TL, TR, BL, BR
  let centres = ((cx - off, cy - off), (cx + off, cy - off),
                 (cx - off, cy + off), (cx + off, cy + off))
  for (i, c) in centres.enumerate() {
    place(top + left, dx: (c.at(0) - d / 2) * 1mm - M, dy: (c.at(1) - d / 2) * 1mm - M,
      box(width: d * 1mm, height: d * 1mm, radius: 50%, fill: card-bg,
        stroke: card-stroke, inset: 3mm,
        align(center + horizon,
          text(font: font-body, size: fs-desc, fill: card-ink, quads.at(i)))))
  }
})

// Agenda / contents - a numbered list of the deck's sections. The number carries
// the brand red (the ONE accent on the slide); the section name is a Subhead.
#let agenda(title, items, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  at(16.9, Y2, 180, {
    for (i, it) in items.enumerate() {
      if i > 0 { v(gap-item) }
      let no = if i + 1 < 10 { "0" + str(i + 1) } else { str(i + 1) }
      grid(columns: (16mm, auto), column-gutter: 4mm, align: (left + horizon, horizon),
        text(font: font-display, size: fs-item, weight: "bold", fill: accent, no),
        subh(it))
    }
  })
})

// KPI row - several big figures in a line (unlike `stat`, which is ONE). Each is
// a number (H1 display) with a Subhead label; the pair is tight (one metric).
#let kpis(title, items, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  let n = items.len()
  let w = (CW / 1mm - gut-card * (n - 1)) / n
  for (i, it) in items.enumerate() {
    at(16.9 + i * (w + gut-card), 62, w, {
      disp(fs-lead2, it.at(0))
      v(gap-fig-label)
      subh(it.at(1))
    })
  }
})

// Timeline - a horizontal spine with a red node per stage; label AND description
// both sit BELOW the node, stacked, so every stage reads the same distance from
// its dot (no arbitrary above/below split).
#let timeline(title, steps, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  let n = steps.len()
  let y = 60.0
  let seg = (CW / 1mm) / n
  // the spine
  place(top + left, dx: 16.9mm - M, dy: y * 1mm - M,
    box(width: CW, height: 1.2pt, fill: ink-soft))
  for (i, st) in steps.enumerate() {
    let cx = 16.9 + seg * (i + 0.5)
    // node
    place(top + left, dx: (cx - 1.8) * 1mm - M, dy: (y - 1.8) * 1mm - M,
      box(width: 3.6mm, height: 3.6mm, radius: 50%, fill: accent))
    // label + description stacked below the node, one fixed gap from the dot
    at(cx - seg / 2 + 3, y + 7, seg - 6, align(center, {
      lbl(st.at(0), fill: ink)
      v(gap-label-body)
      bd(fs-desc, st.at(1))
    }))
  }
})

// Table - header row (H3 labels) + body rows (Body), hairline under every row.
// Neutral, template-grey rules - no heavy borders.
#let table-slide(title, headers, rows, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  at(16.9, Y2, CW / 1mm, {
    let ncol = headers.len()
    table(
      columns: (1fr,) * ncol,
      align: left + horizon,
      inset: (x: 4mm, y: 3.6mm),
      stroke: (x, y) => (bottom: 0.6pt + ink-soft),
      table.header(..headers.map(h => lbl(h, fill: ink))),
      ..rows.map(r => r.map(c => bd(fs-desc, c))).flatten(),
    )
  })
})

// Callout - a pulled-out remark with the brand red rule down its left edge, set
// large (H2). The heavier sibling of `noted`: for a single important line, not a
// footnote. Optional supporting Subhead under it.
#let callout(body, sub: none, tag: none) = slide-raw(tag: tag, {
  vblock(bigw, grid(
    columns: (3.5pt, auto), column-gutter: 9mm, align: (left, horizon),
    box(width: 3.5pt, height: 32mm, fill: accent),
    box(width: 178mm, {
      hd(fs-head, par(leading: lead-head, body))
      if sub != none { v(gap-head-body); subh(sub) }
    }),
  ))
})

// =============================================================================
// EXTENDED VOCABULARY  (lifted from the full "Slides" template variations)
// Small shared pieces first, then one layout per template archetype.
// =============================================================================

// grey placeholder for an image/screenshot that isn't in yet (template checker-
// board), as a rounded card with a hairline border and an optional caption.
#let ph(w, h, label: none) = box(width: w, height: h, radius: card-r,
  fill: card-bg, stroke: card-stroke,
  if label != none { place(center + horizon, cap(label)) })

// a real image if given, else the placeholder - same footprint either way.
#let visual(w, h, img: none, label: none) = if img != none {
  box(width: w, height: h, radius: card-r, clip: true,
    image(img, width: 100%, height: 100%, fit: "cover"))
} else { ph(w, h, label: label) }

// grey avatar disc (team / testimonial placeholder).
#let avatar(d) = box(width: d, height: d, radius: 50%, fill: card-bg, stroke: card-stroke)

// ---- Highlight (template slide 6): a single labelled remark - bold label on the
// left band, one explanatory paragraph on the right, lots of air.
#let highlight(label, body, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, hd(fs-head, label)))
  place(horizon + left, dx: 128.1mm - M,
    box(width: colw * 1mm, bd(fs-desc, par(leading: 0.6em, body))))
})

// ---- Open columns (template slides 9/10): heading + lead at the top, then a row
// of (label, body) items on the OPEN page - no cards, unlike `cards`. 3 or 4 up.
#let columns(title, items, lead: none, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, {
    hd(fs-head, title)
    if lead != none { v(gap-head-body); subh(lead) }
  })
  let n = items.len()
  let g = 8
  let w = (CW / 1mm - g * (n - 1)) / n
  for (i, it) in items.enumerate() {
    at(16.9 + i * (w + g), 80, w, {
      lbl(it.at(0), fill: ink)
      v(gap-label-body)
      bd(fs-desc, par(leading: 0.6em, it.at(1)))
    })
  }
})

// ---- Feature grid (template slide 8): heading on the left band, four (label,
// body) items in a 2x2 grid on the right half.
#let feature-grid(title, items, lead: none, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, title)
    if lead != none { v(gap-head-body); subh(lead) }
  }))
  let x0 = 128.1
  let cw = 49.5
  let gx = 10
  let ys = (44, 88)
  for (i, it) in items.enumerate() {
    let cx = x0 + calc.rem(i, 2) * (cw + gx)
    let cy = ys.at(calc.quo(i, 2))
    at(cx, cy, cw, {
      lbl(it.at(0), fill: ink)
      v(gap-label-body)
      bd(fs-desc, par(leading: 0.6em, it.at(1)))
    })
  }
})

// Metric number size is UNIFIED: a single hero figure (stat, big-metric) is
// fs-title (36.6); a GROUP of figures (kpis, metric-cols, metric-grid,
// metric-list) is fs-lead2 (23.4) - smaller reads calmer in a row, and every
// multi-metric slide now matches (every metric slide must be unified, and the
// smaller number read better). num->label gap is the
// same gap-label-body everywhere.

// ---- Metric list (template slide 19): heading on the left band, a vertical
// stack of rows on the right, each a big figure + label + a normal-size line.
#let metric-list(title, items, lead: none, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: 84mm, {
    hd(fs-head, title)
    if lead != none { v(gap-head-body); subh(lead) }
  }))
  let n = items.len()
  let top = 42
  let rowh = 80 / n
  for (i, it) in items.enumerate() {
    at(112, top + i * rowh, 128, grid(
      columns: (40mm, auto), column-gutter: 7mm, align: (left, horizon),
      disp(fs-lead2, it.at(0)),
      // description is body size, not a tiny caption - there is room and normal
      // text reads better here.
      { lbl(it.at(1), fill: ink); v(2.4mm); bd(fs-desc, it.at(2)) },
    ))
  }
})

// ---- Metric columns (template slide 20): heading at the top, a row of figures
// each with a full descriptive paragraph (heavier than `kpis`, which pairs a
// number with a one-line label).
#let metric-cols(title, items, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  let n = items.len()
  let g = 12
  let w = (CW / 1mm - g * (n - 1)) / n
  for (i, it) in items.enumerate() {
    at(16.9 + i * (w + g), 60, w, {
      disp(fs-lead2, it.at(0))
      v(gap-fig-label)
      bd(fs-desc, par(leading: 0.6em, it.at(1)))
    })
  }
})

// ---- Metric grid (template slide 21): heading + description on the left band,
// a 2x2 grid of figures with short labels on the right.
#let metric-grid(title, desc, items, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, title)
    v(gap-head-body)
    subh(desc)
  }))
  let x0 = 128.1
  let cw = 52
  let gx = 8
  let ys = (42, 86)
  for (i, it) in items.enumerate() {
    let cx = x0 + calc.rem(i, 2) * (cw + gx)
    let cy = ys.at(calc.quo(i, 2))
    at(cx, cy, cw, {
      disp(fs-lead2, it.at(0))
      v(gap-fig-label)
      subh(it.at(1))
    })
  }
})

// ---- Roadmap (template slide 22): a horizontal spine with milestones that
// ALTERNATE above and below, each a date label + a paragraph. The richer sibling
// of `timeline` (which puts every stage below a bare node).
#let roadmap(title, milestones, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  let n = milestones.len()
  let y = 74.0
  let seg = (CW / 1mm) / n
  let tick = 6.0        // spine -> date, SAME both sides so nearest text is level
  let Cb = H / 1mm - M / 1mm   // content-area bottom in mm (for bottom placement)
  place(top + left, dx: 16.9mm - M, dy: y * 1mm - M,
    box(width: CW, height: 1.2pt, fill: ink))
  let nr = 1.6          // node radius
  for (i, ms) in milestones.enumerate() {
    let cx = 16.9 + seg * (i + 0.5)
    let up = calc.rem(i, 2) == 0
    // node
    place(top + left, dx: (cx - nr) * 1mm - M, dy: (y - nr) * 1mm - M,
      box(width: 2 * nr * 1mm, height: 2 * nr * 1mm, radius: 50%, fill: accent))
    // Vertical tick from the EDGE of the node toward the text, not from its
    // centre: starting at the centre drew a dark line across the red disc
    //.
    place(top + left, dx: cx * 1mm - M,
      dy: (if up { y - tick } else { y + nr }) * 1mm - M,
      box(width: 0.8pt, height: (tick - nr) * 1mm, fill: ink))
    let bx = cx - seg / 2 + 2
    let bw = seg - 8
    // the DATE label is always `tick` mm from the spine (level across all
    // stages); the paragraph flows away from the line. For the up stages the
    // block is bottom-anchored so its date ends `tick` above the spine.
    if up {
      place(bottom + left, dx: bx * 1mm - M, dy: -(Cb - (y - tick)) * 1mm,
        box(width: bw * 1mm, { note(ms.at(1)); v(2.4mm); lbl(ms.at(0), fill: ink) }))
    } else {
      // sit the date right at the tick end so the line reads as attached, not
      // floating over empty air.
      at(bx, y + tick, bw, { lbl(ms.at(0), fill: ink); v(2.4mm); note(ms.at(1)) })
    }
  }
})

// ---- Venn (template slide 26): heading + description on the left band, two
// overlapping translucent discs on the right; the overlap darkens on its own.
#let venn(title, desc, labels, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, title)
    v(gap-head-body)
    subh(desc)
  }))
  let cy = 71.0
  let r = 34.0
  let c1 = 156.0
  let c2 = 196.0
  let disc(cx) = place(top + left, dx: (cx - r) * 1mm - M, dy: (cy - r) * 1mm - M,
    circle(radius: r * 1mm, fill: ink.transparentize(86%), stroke: 0.9pt + ink-soft))
  disc(c1)
  disc(c2)
  at(c1 - 30, cy - 3, 30, align(center, bd(fs-small, labels.at(0), fill: ink)))
  at((c1 + c2) / 2 - 15, cy - 3, 30, align(center, bd(fs-small, labels.at(1), fill: ink)))
  at(c2, cy - 3, 30, align(center, bd(fs-small, labels.at(2), fill: ink)))
})

// ---- Nested (template slide 23): heading + description on the left band, a set
// of concentric rings on the right, innermost filled; a label per ring.
#let nested(title, desc, labels, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, title)
    v(gap-head-body)
    subh(desc)
  }))
  let cx = 178.0
  let cy = 71.0
  let n = labels.len()
  let rmax = 46.0
  let rmin = 15.0
  for i in range(n) {
    let r = rmax - (rmax - rmin) * i / (n - 1)
    place(top + left, dx: (cx - r) * 1mm - M, dy: (cy - r) * 1mm - M,
      circle(radius: r * 1mm, stroke: 1pt + ink,
        fill: if i == n - 1 { card-bg } else { none }))
    at(cx - 22, cy - r + 4.5, 44, align(center, cap(labels.at(i))))
  }
})

// ---- Funnel (template slide 27): heading + description on the left band, an
// inverted funnel of labelled segments on the right.
#let funnel(title, desc, items, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, title)
    v(gap-head-body)
    subh(desc)
  }))
  let n = items.len()
  let cx = 176.0
  let ytop = 28.0
  let htot = 90.0
  let wtop = 108.0
  let wbot = 34.0
  let seg = htot / n
  let gap = 1.4
  for (i, it) in items.enumerate() {
    let y0 = ytop + i * seg
    let w0 = wtop + (wbot - wtop) * (i / n)
    let w1 = wtop + (wbot - wtop) * ((i + 1) / n)
    place(top + left, dx: cx * 1mm - M, dy: y0 * 1mm - M,
      polygon(fill: card-bg, stroke: none,
        (-w0 / 2 * 1mm, 0mm), (w0 / 2 * 1mm, 0mm),
        (w1 / 2 * 1mm, (seg - gap) * 1mm), (-w1 / 2 * 1mm, (seg - gap) * 1mm)))
    place(top + left, dx: (cx - 40) * 1mm - M, dy: (y0 + seg / 2 - 3.5) * 1mm - M,
      box(width: 80mm, align(center, lbl(it, fill: card-ink))))
  }
})

// ---- Testimonial (template slide 37): a single quote centred on the page, with
// an avatar above and a "Name · Location" line below.
#let testimonial(quote, name: none, loc: none, tag: none) = slide-raw(tag: tag, {
  place(horizon + center, box(width: 168mm, align(center, {
    avatar(14mm)
    v(7mm)
    hd(fs-head, par(leading: lead-head)[«#quote».])
    if name != none {
      v(gap-head-body)
      cap(if loc != none { [#name · #loc] } else { name })
    }
  })))
})

// ---- Testimonials row (template slides 38-41): several short quotes side by
// side, each with a "Name · Location" line. Avatars optional.
#let testimonials(items, avatars: true, tag: none) = slide-raw(tag: tag, {
  let n = items.len()
  let g = 10
  let w = (CW / 1mm - g * (n - 1)) / n
  for (i, it) in items.enumerate() {
    place(horizon + left, dx: (16.9 + i * (w + g)) * 1mm - M,
      box(width: w * 1mm, align(if avatars { center } else { left }, {
        if avatars { avatar(11mm); v(5mm) }
        text(font: font-body, size: fs-desc, fill: ink,
          par(leading: 0.62em)[«#it.at(0)».])
        v(4mm)
        cap(it.at(1))
      })))
  }
})

// ---- Team (template slide 42): a centred title with a grid of avatars, each a
// name + role. Wraps to a second row past `perrow`.
#let team(title, members, perrow: 6, tag: none) = slide-raw(tag: tag, {
  at(16.9, 20, 209.6, align(center, hd(fs-head, title)))
  let n = members.len()
  let rows = calc.ceil(n / perrow)
  let cw = (CW / 1mm - 6 * (perrow - 1)) / perrow
  let top = 52
  let rowh = 34
  for (i, mb) in members.enumerate() {
    let r = calc.quo(i, perrow)
    let c = calc.rem(i, perrow)
    // centre the last (possibly short) row
    let inrow = if r < rows - 1 { perrow } else { n - r * perrow }
    let rowW = inrow * cw + 6 * (inrow - 1)
    let x0 = 16.9 + (CW / 1mm - rowW) / 2
    at(x0 + c * (cw + 6), top + r * rowh, cw, align(center, {
      avatar(14mm)
      v(3mm)
      // name = same size as the role (fs-small), just bold: one line, separated
      // from the role by weight alone.
      text(font: font-heading, size: fs-small, weight: "bold", fill: ink, mb.at(0))
      v(1.2mm)
      cap(mb.at(1))
    }))
  }
})

// ---- Image row (template slides 16/17): heading at the top, a row of visuals
// each with a (label, description) caption beneath. 2 or 3 up.
#let image-row(title, items, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, 209.6, hd(fs-head, title))
  let n = items.len()
  let g = 8
  let w = (CW / 1mm - g * (n - 1)) / n
  // images sit higher and taller (there is room above), and the caption's
  // label->body gap is the SAME gap-label-body as everywhere else - the old
  // tight gap made the label stick to its text.
  let ih = 60
  for (i, it) in items.enumerate() {
    at(16.9 + i * (w + g), 42, w, {
      visual(w * 1mm, ih * 1mm, img: it.at(0))
      v(6mm)
      lbl(it.at(1), fill: ink)
      v(gap-label-body)
      bd(fs-desc, par(leading: 0.6em, it.at(2)))
    })
  }
})

// ---- Full image (template slide 15): one visual spanning the content width with
// a single centred caption beneath.
#let image-full(img: none, caption: none, tag: none) = slide-raw(tag: tag, {
  at(16.9, 16.9, CW / 1mm, {
    visual(CW, 96mm, img: img)
    if caption != none { v(5mm); align(center, lbl(caption, fill: ink)) }
  })
})

// ---- Device primitives (template mobile / desktop mockups). Deliberately
// simple - a rounded frame + a placeholder screen, enough to read as "a phone"
// or "a laptop" without pretending to be a photoreal render.
#let phone(h, img: none) = {
  let w = h * 0.49
  box(width: w * 1mm, height: h * 1mm, radius: (h * 0.11) * 1mm, fill: ink,
    inset: (h * 0.014) * 1mm,
    box(width: 100%, height: 100%, radius: (h * 0.095) * 1mm, clip: true,
      fill: card-bg,
      {
        if img != none { image(img, width: 100%, height: 100%, fit: "cover") }
        place(top + center, dy: (h * 0.02) * 1mm,
          box(width: (w * 0.32) * 1mm, height: (h * 0.028) * 1mm,
            radius: (h * 0.014) * 1mm, fill: ink))
      }))
}
#let laptop(w, img: none) = {
  let sh = w * 0.6
  box({
    box(width: w * 1mm, height: sh * 1mm, radius: (w * 0.02) * 1mm, fill: ink,
      inset: (w * 0.01) * 1mm,
      box(width: 100%, height: 100%, radius: (w * 0.014) * 1mm, clip: true,
        fill: card-bg,
        if img != none { image(img, width: 100%, height: 100%, fit: "cover") }))
    // base
    place(top + center, dy: sh * 1mm,
      box(width: (w * 1.12) * 1mm, height: (w * 0.028) * 1mm,
        radius: (w * 0.014) * 1mm, fill: ink))
  })
}

// ---- Mobile showcase (template slides 28-33): text on the left band, one or
// more phone mockups on the right.
#let mobile-showcase(title, body, n: 1, kicker: none, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: 88mm, {
    if kicker != none { kick(kicker); v(gap-label-tight) }
    hd(fs-head, title)
    v(gap-head-body)
    subh(body)
  }))
  // phones shrink as their count grows so the whole row stays inside the right
  // half of the frame (three full-size phones ran off the page edge).
  let ph-h = if n <= 1 { 100 } else if n == 2 { 90 } else { 72 }
  let ph-w = ph-h * 0.49
  let g = 8
  let totalW = n * ph-w + g * (n - 1)
  let cx = 174
  let x0 = cx - totalW / 2
  for i in range(n) {
    place(top + left, dx: (x0 + i * (ph-w + g)) * 1mm - M, dy: (71 - ph-h / 2) * 1mm - M,
      phone(ph-h))
  }
})

// ---- Desktop showcase (template slides 35/36): text on the left band, a laptop
// mockup on the right.
#let desktop-showcase(title, body, kicker: none, tag: none) = slide-raw(tag: tag, {
  place(horizon + left, dx: 16.9mm - M, box(width: 82mm, {
    if kicker != none { kick(kicker); v(gap-label-tight) }
    hd(fs-head, title)
    v(gap-head-body)
    subh(body)
  }))
  let lw = 118
  place(horizon + left, dx: (172 - lw / 2) * 1mm - M, box(laptop(lw)))
})

// ---- Annotated visual (template slides 30/34): a central visual with leader-
// line callouts. `notes` is a list of (side, y, label): side is "left"/"right",
// y is the mm height of the anchor point on the device edge.
#let annotated(title: none, img: none, notes: (), tag: none) = slide-raw(tag: tag, {
  if title != none { at(16.9, 16.9, 209.6, hd(fs-head, title)) }
  let ph-h = 104
  let ph-w = ph-h * 0.49
  let cx = 127.0
  let pty = 71 - ph-h / 2
  let leftEdge = cx - ph-w / 2
  let rightEdge = cx + ph-w / 2
  place(top + left, dx: (cx - ph-w / 2) * 1mm - M, dy: pty * 1mm - M, phone(ph-h))
  for nt in notes {
    let side = nt.at(0)
    let ay = nt.at(1)
    let label = nt.at(2)
    if side == "left" {
      let lx = leftEdge - 34
      place(top + left, dx: lx * 1mm - M, dy: ay * 1mm - M,
        box(width: 34mm, height: 0.8pt, fill: ink-soft))
      at(lx - 34, ay - 3, 34, align(right, cap(label)))
    } else {
      place(top + left, dx: rightEdge * 1mm - M, dy: ay * 1mm - M,
        box(width: 34mm, height: 0.8pt, fill: ink-soft))
      at(rightEdge + 36, ay - 3, 40, cap(label))
    }
  }
})
