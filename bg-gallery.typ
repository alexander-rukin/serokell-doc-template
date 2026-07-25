#import "slides.typ": *

// ---- shared sample content (heading band + 3 mini-blocks, like real slides) --
#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Фон - тихая текстура, текст читается первым.])
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
#let full(x, y, w, h, b) = place(top + left, dx: x * 1mm - M, dy: y * 1mm - M, box(width: w * 1mm, height: h * 1mm, b))

// ============================================================================
// ВОЛНА 1
// ============================================================================
#let dotcol = if dark { white.transparentize(88%) } else { black.transparentize(90%) }
#base([A - точечная сетка], {
  let step = 12
  for gi in range(0, int(W / 1mm / step) + 2) { for gj in range(0, int(H / 1mm / step) + 2) {
    place(top + left, dx: gi * step * 1mm - M, dy: gj * step * 1mm - M, circle(radius: 0.4mm, fill: dotcol, stroke: none)) } }
})

#let blobcol = if dark { white.transparentize(93%) } else { black.transparentize(95%) }
#base([B - мягкое пятно в углу], {
  place(top + left, dx: (W / 1mm - 30) * 1mm - M, dy: (-40) * 1mm - M, circle(radius: 80mm, fill: blobcol, stroke: none))
  place(top + left, dx: (-30) * 1mm - M, dy: (H / 1mm - 20) * 1mm - M, circle(radius: 55mm, fill: none, stroke: 1.2pt + blobcol))
})

#let ghostcol = if dark { white.transparentize(92%) } else { black.transparentize(93%) }
#base([C - призрачная цифра], {
  place(bottom + left, dx: -8mm, dy: 34mm, text(font: font-display, size: 300pt, fill: ghostcol, weight: "bold", [06]))
})

#let linecol = if dark { white.transparentize(91%) } else { black.transparentize(92%) }
#base([D - колоночные направляющие], {
  let cols = 12
  let cw = (W / 1mm) / cols
  for c in range(1, cols) { place(top + left, dx: c * cw * 1mm - M, dy: -M, rect(width: 0.5pt, height: H, fill: linecol, stroke: none)) }
})

// ============================================================================
// ВОЛНА 2
// ============================================================================
#base([E - красный акцент-штрих], {
  place(top + left, dx: -M, dy: 26mm - M, rect(width: 34mm, height: 2.2pt, fill: accent))
  place(bottom + left, dx: 16.9mm - M, dy: -20mm, rect(width: 7mm, height: 7mm, fill: accent.transparentize(20%)))
})

#let cline = if dark { white.transparentize(84%) } else { black.transparentize(87%) }
#base([F - контурные линии], {
  for k in range(0, 6) { place(top + left, dx: (W / 1mm - 6) * 1mm - M, dy: (H / 1mm + 4) * 1mm - M, circle(radius: (18 + k * 13) * 1mm, fill: none, stroke: 1.1pt + cline)) }
})

#let hcol = if dark { white.transparentize(90%) } else { black.transparentize(91%) }
#base([G - диагональная штриховка], {
  for i in range(0, 26) { let off = i * 6
    place(top + left, dx: (W / 1mm - 70 + off) * 1mm - M, dy: -M, rotate(-45deg, origin: top + left, rect(width: 0.5pt, height: 150mm, fill: hcol))) }
})

#let gc0 = if dark { white.transparentize(90%) } else { black.transparentize(92%) }
#base([H - мягкий радиальный глоу], {
  place(top + left, dx: (W / 1mm - 20) * 1mm - M, dy: (-30) * 1mm - M, circle(radius: 95mm, stroke: none, fill: gradient.radial(gc0, bg.transparentize(100%), center: (50%, 50%))))
})

#let gcol = if dark { white.transparentize(86%) } else { black.transparentize(88%) }
#base([I - редкое зерно], {
  for i in range(0, 220) { let x = calc.rem(i * 73 + 11, 250); let y = calc.rem(i * 149 + 37, 139); let r = 0.18mm + 0.12mm * calc.rem(i, 3)
    place(top + left, dx: x * 1mm - M, dy: y * 1mm - M, circle(radius: r, fill: gcol, stroke: none)) }
})

#let acol = if dark { white.transparentize(83%) } else { black.transparentize(86%) }
#base([J - дуга-горизонт], {
  place(top + left, dx: (-40) * 1mm - M, dy: (H / 1mm - 4) * 1mm - M, circle(radius: 150mm, fill: none, stroke: 1.6pt + acol))
})

// ============================================================================
// ВОЛНА 3
// ============================================================================
#let frcol = if dark { white.transparentize(86%) } else { black.transparentize(88%) }
#base([K - тонкая рамка-кайма], {
  place(top + left, dx: 7mm - M, dy: 7mm - M, rect(width: W - 14mm, height: H - 14mm, fill: none, stroke: 0.6pt + frcol, radius: 1mm))
})

#let crcol = if dark { white.transparentize(72%) } else { black.transparentize(74%) }
#base([L - уголковые засечки (crop marks)], {
  let arm = 6mm
  let ins = 9
  let corner(cx, cy, sx, sy) = {
    place(top + left, dx: cx * 1mm - M, dy: cy * 1mm - M, rect(width: arm * sx, height: 0.7pt, fill: crcol))
    place(top + left, dx: cx * 1mm - M, dy: cy * 1mm - M, rect(width: 0.7pt, height: arm * sy, fill: crcol))
  }
  corner(ins, ins, 1, 1)
  corner(W / 1mm - ins, ins, -1, 1)
  corner(ins, H / 1mm - ins, 1, -1)
  corner(W / 1mm - ins, H / 1mm - ins, -1, -1)
})

#let bandcol = if dark { white.transparentize(94%) } else { black.transparentize(96%) }
#base([M - боковая тональная плашка], {
  full(0, 0, 108, H / 1mm, rect(width: 100%, height: 100%, fill: bandcol, stroke: none))
})

#let pcol = if dark { white.transparentize(87%) } else { black.transparentize(89%) }
#base([N - сетка технических крестов], {
  let step = 20
  let a = 1.1mm
  for gi in range(0, int(W / 1mm / step) + 2) { for gj in range(0, int(H / 1mm / step) + 2) {
    let px = gi * step; let py = gj * step
    place(top + left, dx: (px * 1mm) - a - M, dy: py * 1mm - M, rect(width: 2 * a, height: 0.5pt, fill: pcol))
    place(top + left, dx: px * 1mm - M, dy: (py * 1mm) - a - M, rect(width: 0.5pt, height: 2 * a, fill: pcol)) } }
})

#let g1 = if dark { white.transparentize(93%) } else { black.transparentize(95%) }
#base([O - тональный градиент], {
  full(0, 0, W / 1mm, H / 1mm, rect(width: 100%, height: 100%, stroke: none,
    fill: gradient.linear(bg.transparentize(100%), g1, angle: 90deg)))
})

#base([P - красный уголок-скоба], {
  let arm = 26mm
  place(top + left, dx: 12mm - M, dy: 12mm - M, rect(width: arm, height: 2pt, fill: accent))
  place(top + left, dx: 12mm - M, dy: 12mm - M, rect(width: 2pt, height: arm, fill: accent))
})

// ============================================================================
// ВОЛНА 4  (развиваю то что зашло: A - точки/сетки, M - тональные плашки)
// ============================================================================
#base([Q - плотная точка-сетка], {
  let step = 7
  for gi in range(0, int(W / 1mm / step) + 2) { for gj in range(0, int(H / 1mm / step) + 2) {
    place(top + left, dx: gi * step * 1mm - M, dy: gj * step * 1mm - M, circle(radius: 0.28mm, fill: dotcol, stroke: none)) } }
})

#base([R - затухающая точка-сетка], {
  let step = 10
  let cols = int(W / 1mm / step) + 2
  for gi in range(0, cols) {
    let t = gi / cols
    let col = if dark { white.transparentize((80 + 18 * t) * 1%) } else { black.transparentize((82 + 16 * t) * 1%) }
    for gj in range(0, int(H / 1mm / step) + 2) {
      place(top + left, dx: gi * step * 1mm - M, dy: gj * step * 1mm - M, circle(radius: 0.4mm, fill: col, stroke: none)) }
  }
})

#base([S - полутон (растущие точки)], {
  let step = 9
  let rows = int(H / 1mm / step) + 2
  for gj in range(0, rows) {
    let t = gj / rows
    let r = (0.12 + 0.55 * t) * 1mm
    for gi in range(0, int(W / 1mm / step) + 2) {
      place(top + left, dx: gi * step * 1mm - M, dy: gj * step * 1mm - M, circle(radius: r, fill: dotcol, stroke: none)) }
  }
})

#base([T - правая тональная панель], {
  full(146, 0, 108, H / 1mm, rect(width: 100%, height: 100%, fill: bandcol, stroke: none))
})

#base([U - плашка с точками (M+A)], {
  full(0, 0, 108, H / 1mm, rect(width: 100%, height: 100%, fill: bandcol, stroke: none))
  let step = 11
  for gi in range(0, int(108 / step) + 1) { for gj in range(0, int(H / 1mm / step) + 2) {
    place(top + left, dx: gi * step * 1mm - M, dy: gj * step * 1mm - M, circle(radius: 0.4mm, fill: dotcol, stroke: none)) } }
})

#base([V - нижняя тональная полоса], {
  full(0, H / 1mm - 34, W / 1mm, 34, rect(width: 100%, height: 100%, fill: bandcol, stroke: none))
})
