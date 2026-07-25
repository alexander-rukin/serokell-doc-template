#import "slides.typ": *

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

#let base(body) = page(width: W, height: H, margin: M, fill: bg, {
  set text(font: font-body, fill: ink, size: fs-desc)
  set par(leading: 0.6em, spacing: 0pt)
  set block(spacing: 0pt)
  body
  sample-content
  place(bottom + right, dy: FOOT_DROP, logo-box)
})

// ============ E. Один красный акцент-штрих (brand tick) ======================
// the ONLY colour in the system, used as a quiet structural mark, not decoration
#base({
  lab([E - красный акцент-штрих])
  // a thin red rule bleeding off the top-left, + a tiny red square bottom-right
  place(top + left, dx: -M, dy: 26mm - M, rect(width: 34mm, height: 2.2pt, fill: accent))
  place(bottom + left, dx: 16.9mm - M, dy: -20mm, rect(width: 7mm, height: 7mm, fill: accent.transparentize(20%)))
})

// ============ F. Топографика / контурные линии (contour) =====================
#let cline = if dark { white.transparentize(84%) } else { black.transparentize(87%) }
#base({
  lab([F - контурные линии])
  // nested offset arcs bleeding off the bottom-right, like a topographic map
  for k in range(0, 6) {
    place(top + left, dx: (W / 1mm - 6) * 1mm - M, dy: (H / 1mm + 4) * 1mm - M,
      circle(radius: (18 + k * 13) * 1mm, fill: none, stroke: 1.1pt + cline))
  }
})

// ============ G. Диагональная штриховка в углу (hatch) =======================
#let hcol = if dark { white.transparentize(90%) } else { black.transparentize(91%) }
#base({
  lab([G - диагональная штриховка])
  // a corner patch of thin 45deg lines, top-right, fading structural texture
  let n = 26
  for i in range(0, n) {
    let off = i * 6
    place(top + left, dx: (W / 1mm - 70 + off) * 1mm - M, dy: -M,
      rotate(-45deg, origin: top + left, rect(width: 0.5pt, height: 150mm, fill: hcol)))
  }
})

// ============ H. Мягкий радиальный глоу (soft vignette) ======================
// a radial gradient disc fading to nothing - a soft glow with NO hard edge
#let gc0 = if dark { white.transparentize(90%) } else { black.transparentize(92%) }
#base({
  lab([H - мягкий радиальный глоу])
  place(top + left, dx: (W / 1mm - 20) * 1mm - M, dy: (-30) * 1mm - M,
    circle(radius: 95mm, stroke: none,
      fill: gradient.radial(gc0, bg.transparentize(100%), center: (50%, 50%))))
})

// ============ I. Мелкий крап / зерно (sparse grain) ==========================
#let gcol = if dark { white.transparentize(86%) } else { black.transparentize(88%) }
#base({
  lab([I - редкое зерно])
  // deterministic pseudo-scatter of tiny dots (no RNG in typst): hash on i
  let n = 220
  for i in range(0, n) {
    let x = calc.rem(i * 73 + 11, 250)
    let y = calc.rem(i * 149 + 37, 139)
    let r = 0.18mm + 0.12mm * calc.rem(i, 3)
    place(top + left, dx: x * 1mm - M, dy: y * 1mm - M, circle(radius: r, fill: gcol, stroke: none))
  }
})

// ============ J. Дуга-горизонт (single sweeping line) ========================
#let acol = if dark { white.transparentize(83%) } else { black.transparentize(86%) }
#base({
  lab([J - дуга-горизонт])
  // one big calm arc sweeping across, echoing the cover mountains, very faint
  place(top + left, dx: (-40) * 1mm - M, dy: (H / 1mm - 4) * 1mm - M,
    circle(radius: 150mm, fill: none, stroke: 1.6pt + acol))
})
