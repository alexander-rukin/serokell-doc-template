#import "slides.typ": *

#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Мягкие крупные формы, тихо, за краем.])
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

// very faint palette - "очень незаметные"
#let f1 = if dark { white.transparentize(95%) } else { black.transparentize(96%) }
#let f2 = if dark { white.transparentize(93%) } else { black.transparentize(94%) }
#let so = if dark { 1.4pt + white.transparentize(90%) } else { 1.4pt + black.transparentize(92%) }

#let disc(cx, cy, r, fill: none, stroke: none) = put(cx - r, cy - r, circle(radius: r * 1mm, fill: fill, stroke: stroke))
#let plaque(x, y, w, h, a, fill) = put(x, y, rotate(a, rect(width: w * 1mm, height: h * 1mm, radius: 22mm, fill: fill, stroke: none)))
#let tri(x, y, s, a, fill) = put(x, y, rotate(a, polygon(fill: fill, stroke: none, (0mm, 0mm), (s * 1mm, 0mm), (s / 2 * 1mm, -s * 1mm))))

// ============ вариации в духе BC (плашки) и BE (трио тихих форм) =============

#base([CA - две плашки, обратная диагональ], {
  plaque(-46, -50, 125, 100, -12deg, f2)
  plaque(158, 78, 128, 104, -12deg, f1)
})

#base([CB - три плашки каскадом], {
  plaque(120, -54, 120, 92, -16deg, f1)
  plaque(40, 40, 110, 86, -16deg, f2)
  plaque(-40, 118, 110, 84, -16deg, f1)
})

#base([CC - круг и плашка], {
  disc(20, 22, 54, fill: f2)
  plaque(150, 84, 130, 100, 10deg, f1)
})

#base([CD - три тихих круга], {
  disc(14, 30, 50, fill: f1)
  disc(210, 12, 42, fill: f2)
  disc(232, 128, 58, fill: f1)
})

#base([CE - плашка и мягкий треугольник], {
  plaque(-40, -44, 128, 100, 8deg, f1)
  tri(196, 150, 92, -14deg, f2)
})

#base([CF - два круга, наложение в углу], {
  disc(226, 30, 60, fill: f2)
  disc(250, 74, 48, fill: f2)
})

#base([CG - трио: круг, плашка, круг], {
  disc(26, 18, 44, fill: f2)
  plaque(150, 96, 120, 92, 12deg, f1)
  disc(214, 40, 26, fill: f1)
})

#base([CH - два мягких треугольника], {
  tri(-24, 96, 96, 6deg, f1)
  tri(150, 150, 104, 200deg, f2)
})

#base([CI - крупная плашка по центру + круг], {
  plaque(70, 8, 150, 120, -6deg, f1)
  disc(238, 118, 46, fill: f2)
})

#base([CJ - асимметричный кластер слева], {
  disc(6, 40, 52, fill: f2)
  plaque(-30, 84, 108, 82, -10deg, f1)
  tri(64, 30, 60, 12deg, f1)
})
