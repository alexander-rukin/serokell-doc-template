#import "slides.typ": *

#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Только обводки, две формы, без пересечений.])
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

// two faint stroke weights (thin hairline vs a touch heavier)
#let s1 = if dark { 1pt + white.transparentize(84%) } else { 1pt + black.transparentize(86%) }
#let s2 = if dark { 1.4pt + white.transparentize(80%) } else { 1.4pt + black.transparentize(82%) }

#let disc(cx, cy, r, stroke) = put(cx - r, cy - r, circle(radius: r * 1mm, fill: none, stroke: stroke))
#let plaque(x, y, w, h, a, stroke) = put(x, y, rotate(a, rect(width: w * 1mm, height: h * 1mm, radius: 24mm, fill: none, stroke: stroke)))

// ===== только ОБВОДКИ: 2 формы, без пересечений, близкие размеры ============

#base([FA - два круга, углы], {
  disc(8, 14, 28, s1)
  disc(246, 130, 26, s1)
})

#base([FB - круг + плашка, углы], {
  disc(14, 18, 28, s1)
  plaque(170, 92, 100, 86, -8deg, s1)
})

#base([FC - две плашки, углы], {
  plaque(-30, -32, 104, 88, -8deg, s1)
  plaque(182, 88, 104, 88, -8deg, s1)
})

#base([FD - два круга, обратная диагональ], {
  disc(240, 20, 27, s1)
  disc(16, 124, 28, s1)
})

#base([FE - плашка снизу + круг сверху], {
  plaque(-28, 84, 102, 86, 8deg, s1)
  disc(234, 24, 27, s1)
})

#base([FF - круг слева + круг справа], {
  disc(10, 66, 28, s1)
  disc(248, 70, 27, s1)
})

// чуть плотнее обводка (s2) - на случай если тонкая совсем теряется
#base([FG - два круга, обводка плотнее], {
  disc(8, 14, 28, s2)
  disc(246, 130, 26, s2)
})

#base([FH - круг + плашка, обводка плотнее], {
  disc(14, 18, 28, s2)
  plaque(170, 92, 100, 86, -8deg, s2)
})
