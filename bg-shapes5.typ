#import "slides.typ": *

#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Две формы близкого размера, без пересечений.])
  }))
  place(horizon + left, dx: 128.1mm - M, box(width: colw * 1mm, {
    let items = (
      ([Первый блок], [Строка-пояснение под заголовком блока.]),
      ([Второй блок], [Фон едва заметен, только намёк.]),
      ([Третий блок], [Крупно, приглушённо, за текстом.]),
    )
    for (i, it) in items.enumerate() {
      if i > 0 { v(11mm) }
      lbl(it.at(0), fill: ink); v(gap-label-body); bd(fs-desc, it.at(1))
    }
  }))
}
#let lab(t) = place(top + left, dx: 18mm - M, dy: 8mm - M,
  text(font: font-heading, size: fs-small, fill: ink-soft, weight: "bold", t))
#let base(l, body) = page(width: W, height: H, margin: M, fill: bg, {
  set text(font: font-body, fill: ink, size: fs-desc)
  set par(leading: 0.6em, spacing: 0pt)
  set block(spacing: 0pt)
  body
  lab(l)
  sample-content
  place(bottom + right, dy: FOOT_DROP, logo-box)
})
#let put(x, y, b) = place(top + left, dx: x * 1mm - M, dy: y * 1mm - M, b)

#let f1 = if dark { white.transparentize(95%) } else { black.transparentize(96%) }
#let f2 = if dark { white.transparentize(93%) } else { black.transparentize(94%) }

// close sizes: circles r 26..29 ; plaques ~100-108 wide, 84-92 tall (visible mass
// comparable to a circle since they bleed off the edge). generous corner radius.
#let disc(cx, cy, r, fill) = put(cx - r, cy - r, circle(radius: r * 1mm, fill: fill, stroke: none))
#let plaque(x, y, w, h, a, fill) = put(x, y, rotate(a, rect(width: w * 1mm, height: h * 1mm, radius: 24mm, fill: fill, stroke: none)))

// ===== 2 формы, БЕЗ пересечений, близкие размеры, круги/скругления ==========

#base([EA - два круга, углы], {
  disc(8, 14, 28, f1)
  disc(246, 130, 26, f2)
})

#base([EB - круг + плашка, углы], {
  disc(14, 18, 28, f2)
  plaque(170, 92, 100, 86, -8deg, f1)
})

#base([EC - две плашки, углы], {
  plaque(-30, -32, 104, 88, -8deg, f2)
  plaque(182, 88, 104, 88, -8deg, f1)
})

#base([ED - два круга, обратная диагональ], {
  disc(240, 20, 27, f2)
  disc(16, 124, 28, f1)
})

#base([EE - плашка снизу + круг сверху], {
  plaque(-28, 84, 102, 86, 8deg, f1)
  disc(234, 24, 27, f2)
})

#base([EF - две плашки, верх и низ], {
  plaque(52, -40, 108, 86, 0deg, f2)
  plaque(150, 116, 108, 86, 0deg, f1)
})

#base([EG - круг сверху + плашка снизу], {
  disc(210, 18, 28, f2)
  plaque(-26, 96, 104, 86, -6deg, f1)
})

#base([EH - круг слева + круг справа], {
  disc(10, 66, 28, f1)
  disc(248, 70, 27, f2)
})
