#import "slides.typ": *

#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Ровно две формы, круги и скругления, тихо.])
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

#let disc(cx, cy, r, fill) = put(cx - r, cy - r, circle(radius: r * 1mm, fill: fill, stroke: none))
#let plaque(x, y, w, h, a, fill) = put(x, y, rotate(a, rect(width: w * 1mm, height: h * 1mm, radius: 24mm, fill: fill, stroke: none)))

// ===== ровно 2 формы, только круги и скруглённые прямоугольники =============

#base([DA - два круга, диагональ], {
  disc(4, 6, 58, f1)
  disc(248, 132, 46, f2)
})

#base([DB - круг + плашка], {
  disc(22, 24, 50, f2)
  plaque(150, 86, 128, 100, 10deg, f1)
})

#base([DC - две плашки, диагональ], {
  plaque(-46, -50, 125, 100, -12deg, f2)
  plaque(160, 80, 126, 102, -12deg, f1)
})

#base([DD - два круга, наложение в углу], {
  disc(228, 28, 60, f2)
  disc(250, 74, 46, f2)
})

#base([DE - плашка сверху + круг снизу], {
  plaque(70, -54, 150, 110, -6deg, f1)
  disc(210, 120, 44, f2)
})

#base([DF - большой круг слева + плашка], {
  disc(6, 40, 60, f1)
  plaque(158, 70, 122, 96, 8deg, f2)
})

#base([DG - крупная плашка + малый круг], {
  plaque(148, 8, 132, 122, -8deg, f1)
  disc(24, 116, 40, f2)
})

#base([DH - два круга по вертикали], {
  disc(34, 20, 44, f2)
  disc(206, 122, 54, f1)
})

#base([DI - две плашки, противоположные углы], {
  plaque(-40, 80, 112, 86, -10deg, f2)
  plaque(170, -42, 120, 92, -10deg, f1)
})

#base([DJ - круг с наложением на плашку], {
  plaque(150, 60, 130, 104, 6deg, f1)
  disc(150, 70, 40, f2)
})
