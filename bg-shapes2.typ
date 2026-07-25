#import "slides.typ": *

#let sample-content = {
  place(horizon + left, dx: 16.9mm - M, box(width: colw * 1mm, {
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Две-три большие формы, очень тихо, за краем.])
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

// very faint fills / strokes - "очень незаметные"
#let f1 = if dark { white.transparentize(95%) } else { black.transparentize(96%) }
#let f2 = if dark { white.transparentize(93%) } else { black.transparentize(94%) }
#let so = if dark { 1.4pt + white.transparentize(90%) } else { 1.4pt + black.transparentize(92%) }
#let rf = if dark { accent.transparentize(90%) } else { accent.transparentize(92%) }

// centre-anchored big circle (x,y = centre in mm)
#let disc(x, y, r, fill: none, stroke: none) = put(x - r, y - r, circle(radius: r * 1mm, fill: fill, stroke: stroke))

// ============ BA. Два больших круга по диагонали ============================
#base([BA - два круга по диагонали], {
  disc(6, 4, 58, fill: f1)
  disc(250, 138, 52, fill: f2)
})

// ============ BB. Огромный круг + треугольник ===============================
#base([BB - круг и треугольник], {
  disc(238, 58, 66, fill: f1)
  put(-24, 150, rotate(-12deg, polygon(fill: f2, stroke: none, (0mm, 0mm), (95mm, 0mm), (48mm, -95mm))))
})

// ============ BC. Две скруглённые плашки по диагонали =======================
#base([BC - две скруглённые плашки], {
  put(150, -46, rotate(-14deg, rect(width: 130mm, height: 105mm, radius: 22mm, fill: f2, stroke: none)))
  put(-46, 92, rotate(-14deg, rect(width: 120mm, height: 100mm, radius: 22mm, fill: f1, stroke: none)))
})

// ============ BD. Залитый круг + контурный круг =============================
#base([BD - залитый и контурный круг], {
  disc(10, 14, 60, fill: f1)
  disc(244, 128, 58, stroke: so)
})

// ============ BE. Три очень тихие формы ====================================
#base([BE - три тихие формы], {
  disc(30, 20, 46, fill: f1)
  put(206, 96, rotate(20deg, rect(width: 74mm, height: 74mm, radius: 14mm, fill: f2, stroke: none)))
  put(120, -30, rotate(8deg, polygon(fill: f1, stroke: none, (0mm, 0mm), (70mm, 0mm), (35mm, -70mm))))
})

// ============ BF. Минимум: один контур + один намёк красного ================
#base([BF - контур + намёк красного], {
  disc(28, 130, 66, stroke: so)
  disc(236, 26, 54, fill: rf)
})
