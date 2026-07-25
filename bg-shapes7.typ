#import "slides.typ": *

#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Контур, две формы, ещё прозрачнее.])
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

// three faintness levels (light / dark): pick one to lock the opacity
#let sA = if dark { 1pt + white.transparentize(85%) } else { 1pt + black.transparentize(87%) }
#let sB = if dark { 1pt + white.transparentize(88%) } else { 1pt + black.transparentize(90%) }
#let sC = if dark { 1pt + white.transparentize(91%) } else { 1pt + black.transparentize(93%) }

#let disc(cx, cy, r, stroke) = put(cx - r, cy - r, circle(radius: r * 1mm, fill: none, stroke: stroke))
#let plaque(x, y, w, h, a, stroke) = put(x, y, rotate(a, rect(width: w * 1mm, height: h * 1mm, radius: 24mm, fill: none, stroke: stroke)))

// ===== ЛЕСЕНКА прозрачности на одной раскладке (два круга) ==================
#base([Уровень 1 - чуть тише (transp 87%)], { disc(8, 14, 28, sA); disc(246, 130, 26, sA) })
#base([Уровень 2 - прозрачнее (transp 90%)], { disc(8, 14, 28, sB); disc(246, 130, 26, sB) })
#base([Уровень 3 - совсем призрак (transp 93%)], { disc(8, 14, 28, sC); disc(246, 130, 26, sC) })

// ===== набор раскладок на среднем уровне (sB) ==============================
#base([GA - два круга, углы (sB)], { disc(8, 14, 28, sB); disc(246, 130, 26, sB) })
#base([GB - круг + плашка (sB)], { disc(14, 18, 28, sB); plaque(170, 92, 100, 86, -8deg, sB) })
#base([GC - две плашки (sB)], { plaque(-30, -32, 104, 88, -8deg, sB); plaque(182, 88, 104, 88, -8deg, sB) })
#base([GD - два круга, обратная диагональ (sB)], { disc(240, 20, 27, sB); disc(16, 124, 28, sB) })
#base([GE - плашка снизу + круг сверху (sB)], { plaque(-28, 84, 102, 86, 8deg, sB); disc(234, 24, 27, sB) })
#base([GF - круг слева + круг справа (sB)], { disc(10, 66, 28, sB); disc(248, 70, 27, sB) })
