#import "slides.typ": *

#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Фигуры на фоне, текст всё равно читается первым.])
  }))
  place(horizon + left, dx: 128.1mm - M, box(width: colw * 1mm, {
    let items = (
      ([Первый блок], [Строка-пояснение под заголовком блока.]),
      ([Второй блок], [Фон живее, но не спорит с текстом.]),
      ([Третий блок], [Абстрактные формы, приглушённо.]),
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

// deterministic pseudo-random (no RNG in typst): hash on index
#let rx(i, s) = calc.rem(i * 97 + s * 53 + 17, 250)     // 0..249 mm
#let ry(i, s) = calc.rem(i * 61 + s * 29 + 7, 139)      // 0..138 mm
#let rs(i, s, lo, hi) = lo + calc.rem(i * 37 + s * 13, hi - lo)
#let rrot(i, s) = calc.rem(i * 47 + s * 11, 180) * 1deg

#let grey = if dark { white } else { black }
#let put(x, y, b) = place(top + left, dx: x * 1mm - M, dy: y * 1mm - M, b)

// ============ AA. Мелкие разбросанные примитивы =============================
#base([AA - мелкие фигуры вразброс], {
  let pal = (grey.transparentize(87%), grey.transparentize(90%), grey.transparentize(84%), accent.transparentize(72%))
  for i in range(0, 26) {
    let s = rs(i, 3, 5, 20); let c = pal.at(calc.rem(i * 13 + 3, pal.len())); let k = calc.rem(i + 1, 4)
    put(rx(i, 3), ry(i, 3), if k == 0 { circle(radius: s / 2 * 1mm, fill: c, stroke: none) }
      else if k == 1 { rect(width: s * 1mm, height: s * 1mm, radius: 1mm, fill: c, stroke: none) }
      else if k == 2 { rotate(45deg, rect(width: s * 1mm, height: s * 1mm, fill: c, stroke: none)) }
      else { polygon(fill: c, stroke: none, (0mm, 0mm), (s * 1mm, 0mm), (s / 2 * 1mm, -s * 1mm)) })
  }
})

// ============ AB. Крупные полупрозрачные фигуры (bleed) ======================
#base([AB - крупные полупрозрачные], {
  let pal = (grey.transparentize(92%), grey.transparentize(90%), accent.transparentize(88%))
  let defs = ((-20, -15, 78, 0), (200, 90, 64, 1), (150, -30, 70, 2), (30, 120, 58, 0), (240, 10, 50, 2))
  for (idx, d) in defs.enumerate() {
    let c = pal.at(calc.rem(idx, pal.len()))
    put(d.at(0), d.at(1), if d.at(3) == 0 { circle(radius: d.at(2) / 2 * 1mm, fill: c, stroke: none) }
      else if d.at(3) == 1 { rect(width: d.at(2) * 1mm, height: d.at(2) * 1mm, radius: 8mm, fill: c, stroke: none) }
      else { rotate(18deg, polygon(fill: c, stroke: none, (0mm, 0mm), (d.at(2) * 1mm, 0mm), (d.at(2) / 2 * 1mm, -d.at(2) * 1mm))) })
  }
})

// ============ AC. Контурные фигуры (только обводка) =========================
#base([AC - контурные фигуры], {
  let st = if dark { 1pt + white.transparentize(80%) } else { 1pt + black.transparentize(82%) }
  for i in range(0, 15) {
    let s = rs(i, 8, 8, 28); let k = calc.rem(i + 2, 3)
    put(rx(i, 8), ry(i, 8), if k == 0 { circle(radius: s / 2 * 1mm, fill: none, stroke: st) }
      else if k == 1 { rotate(rrot(i, 8), rect(width: s * 1mm, height: s * 1mm, fill: none, stroke: st)) }
      else { polygon(fill: none, stroke: st, (0mm, 0mm), (s * 1mm, 0mm), (s / 2 * 1mm, -s * 1mm)) })
  }
})

// ============ AD. Мемфис (фигуры + красные акценты) =========================
#base([AD - мемфис], {
  let g = grey.transparentize(86%); let go = if dark { 1.4pt + white.transparentize(78%) } else { 1.4pt + black.transparentize(80%) }
  let r = accent.transparentize(55%)
  put(20, 30, circle(radius: 9mm, fill: g, stroke: none))
  put(210, 20, rotate(20deg, rect(width: 16mm, height: 16mm, fill: none, stroke: go)))
  put(175, 100, polygon(fill: r, stroke: none, (0mm, 0mm), (14mm, 0mm), (7mm, -14mm)))
  put(60, 110, circle(radius: 5mm, fill: r, stroke: none))
  put(120, 18, rotate(45deg, rect(width: 11mm, height: 11mm, fill: g, stroke: none)))
  put(235, 60, circle(radius: 7mm, fill: none, stroke: go))
  // a little squiggle from short rotated dashes
  for j in range(0, 6) { put(90 + j * 6, 95 + calc.rem(j, 2) * 5, rotate(-30deg, rect(width: 8mm, height: 1.4pt, fill: grey.transparentize(70%)))) }
  put(15, 70, polygon(fill: none, stroke: go, (0mm, 0mm), (13mm, 0mm), (6.5mm, -13mm)))
})

// ============ AE. Плавающие круги (bubbles) =================================
#base([AE - плавающие круги], {
  for i in range(0, 15) {
    let s = rs(i, 5, 6, 40); let out = calc.rem(i, 3) == 0
    let c = grey.transparentize(89%); let st = if dark { 1pt + white.transparentize(82%) } else { 1pt + black.transparentize(84%) }
    put(rx(i, 5), ry(i, 5), circle(radius: s / 2 * 1mm, fill: if out { none } else { c }, stroke: if out { st } else { none }))
  }
})

// ============ AF. Абстрактные штрихи и дуги =================================
#base([AF - штрихи и дуги], {
  let st = if dark { 1.2pt + white.transparentize(80%) } else { 1.2pt + black.transparentize(82%) }
  let sta = if dark { 1.2pt + white.transparentize(86%) } else { 1.2pt + black.transparentize(88%) }
  for i in range(0, 12) {
    let len = rs(i, 6, 16, 60)
    put(rx(i, 6), ry(i, 6), rotate(rrot(i, 6), rect(width: len * 1mm, height: 1.2pt, fill: if dark { white.transparentize(80%) } else { black.transparentize(82%) })))
  }
  // a few big faint arcs (circle outlines bleeding off)
  put(-30, 120, circle(radius: 60mm, fill: none, stroke: sta))
  put(210, -20, circle(radius: 50mm, fill: none, stroke: sta))
  put(120, 60, circle(radius: 34mm, fill: none, stroke: sta))
})
