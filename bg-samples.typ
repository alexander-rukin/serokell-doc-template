#import "slides.typ": *

// sample content = a heading band + 3 mini-blocks, like the real content slides,
// so each background treatment is judged WITH text on top (legibility first).
#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Фон - чистый шум, текст читается первым.])
  }))
  place(horizon + left, dx: 128.1mm - M, box(width: colw * 1mm, {
    let items = (
      ([Первый блок], [Строка-пояснение под заголовком блока.]),
      ([Второй блок], [Фон не должен спорить с этим текстом.]),
      ([Третий блок], [Приглушённо, как тихая текстура.]),
    )
    for (i, it) in items.enumerate() {
      if i > 0 { v(11mm) }
      lbl(it.at(0), fill: ink); v(gap-label-body); bd(fs-desc, it.at(1))
    }
  }))
}

#let base(body) = page(width: W, height: H, margin: M, fill: bg, {
  set text(font: font-body, fill: ink, size: fs-desc)
  set par(leading: 0.6em, spacing: 0pt)
  set block(spacing: 0pt)
  body
  sample-content
  place(bottom + right, dy: FOOT_DROP, logo-box)
})

// ============ A. Точечная сетка (blueprint dot-grid) =========================
#let dotcol = if dark { white.transparentize(88%) } else { black.transparentize(90%) }
#base({
  place(top + left, dx: 18mm - M, dy: 8mm - M,
    text(font: font-heading, size: fs-small, fill: ink-soft, weight: "bold", [A - точечная сетка]))
  let step = 12
  for gi in range(0, int(W / 1mm / step) + 2) {
    for gj in range(0, int(H / 1mm / step) + 2) {
      place(top + left, dx: gi * step * 1mm - M, dy: gj * step * 1mm - M,
        circle(radius: 0.4mm, fill: dotcol, stroke: none))
    }
  }
})

// ============ B. Мягкое пятно в углу (soft geometric bleed) ==================
#let blobcol = if dark { white.transparentize(93%) } else { black.transparentize(95%) }
#base({
  place(top + left, dx: 18mm - M, dy: 8mm - M,
    text(font: font-heading, size: fs-small, fill: ink-soft, weight: "bold", [B - мягкое пятно в углу]))
  // big faint disc bleeding off the top-right, and a fainter ring bottom-left
  place(top + left, dx: (W / 1mm - 30) * 1mm - M, dy: (-40) * 1mm - M,
    circle(radius: 80mm, fill: blobcol, stroke: none))
  place(top + left, dx: (-30) * 1mm - M, dy: (H / 1mm - 20) * 1mm - M,
    circle(radius: 55mm, fill: none, stroke: 1.2pt + blobcol))
})

// ============ C. Гигантская призрачная цифра (ghost numeral) =================
#let ghostcol = if dark { white.transparentize(92%) } else { black.transparentize(93%) }
#base({
  place(top + left, dx: 18mm - M, dy: 8mm - M,
    text(font: font-heading, size: fs-small, fill: ink-soft, weight: "bold", [C - призрачная типографика]))
  place(bottom + left, dx: -8mm, dy: 34mm,
    text(font: font-display, size: 300pt, fill: ghostcol, weight: "bold", [06]))
})

// ============ D. Тонкая колоночная сетка (system guides) =====================
#let linecol = if dark { white.transparentize(91%) } else { black.transparentize(92%) }
#base({
  place(top + left, dx: 18mm - M, dy: 8mm - M,
    text(font: font-heading, size: fs-small, fill: ink-soft, weight: "bold", [D - колоночные направляющие]))
  // faint vertical guides on the 12-col grid the layouts already use
  let cols = 12
  let cw = (W / 1mm) / cols
  for c in range(1, cols) {
    place(top + left, dx: c * cw * 1mm - M, dy: -M,
      rect(width: 0.5pt, height: H, fill: linecol, stroke: none))
  }
})
