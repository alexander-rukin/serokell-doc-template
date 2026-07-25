// Subhead treatment: two ways to keep it distinct from Body without them reading
// as "two thin levels". A - give it weight (Medium) => 3 weights on screen.
// B - keep it Regular but mute the colour => 2 weights, subhead differs by colour.

#import "slides.typ": *

#slide-raw(tag: "weights", {
  at(16.9, 16.9, 209.6, hd(fs-head, [Подзаголовок: два способа отличить от текста]))

  // Variant A - Medium (3 weights)
  at(16.9, 46, 100, {
    cap[ВАРИАНТ A - подзаголовок Medium]
    v(6mm)
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    subh([Подзаголовок Medium - плотнее тела, полный чёрный.])
    v(gap-head-body)
    bd(fs-desc, [Основной текст идёт следом обычным начертанием. На экране три веса: Bold, Medium, Regular.])
  })

  // Variant B - Regular muted (2 weights)
  at(128.1, 46, 100, {
    cap[ВАРИАНТ B - подзаголовок Regular muted]
    v(6mm)
    hd(fs-head, [Заголовок слайда])
    v(gap-head-body)
    text(font: font-body, size: fs-item, fill: ink-soft,
      [Подзаголовок Regular, но приглушён цветом.])
    v(gap-head-body)
    bd(fs-desc, [Основной текст идёт следом обычным начертанием. Весов два: Bold и Regular, подзаголовок отличает цвет.])
  })
})
