// Type scale specimen - the PROPOSED clean hierarchy. Six fixed text roles,
// each shown at its real size with a spec label saying exactly where it is used.
// One role per job, one job per role - no more "subhead" drifting 15/12/9.6pt.

#import "../../slides.typ": *

#slide-raw(tag: "type-scale", {
  at(16.9, 16.9, 209.6, hd(fs-head, [Шкала текста - шесть ролей]))
  at(16.9, 38, CW / 1mm, {
    let spec(t) = text(font: font-mono, size: fs-small, fill: ink-soft, t)
    grid(columns: (98mm, 1fr), column-gutter: 8mm, row-gutter: 6.5mm, align: horizon,

      disp(fs-title, [Заголовок]),
        spec[H1 · Hero · 36.6pt · Bold · обложка, секция, крупная мысль, число],

      hd(fs-head, [Заголовок]),
        spec[H2 · Заголовок · 18.8pt · Bold · заголовок слайда, цитата],

      text(font: font-heading, size: fs-item, weight: "bold", fill: ink, [Метка]),
        spec[H3 · Лейбл · 15pt · Bold · метка колонки и карточки (редкий)],

      text(font: font-body, size: fs-item, weight: "medium", fill: ink, [Подзаголовок]),
        spec[Подзаголовок · 15pt · Medium · пояснение под H1/H2 (единое)],

      bd(fs-desc, [Основной текст]),
        spec[Body · 12pt · Regular · тезисы, описания, тело карточки],

      bd(fs-small, [Сноска и атрибуция], fill: ink-soft),
        spec[Caption · 9.6pt · Regular · сноска, атрибуция, мета, оси],

      text(font: font-display, size: fs-lead2, weight: "bold", fill: ink, [1]),
        spec[Цифра · 23.4pt · Bold · номер шага (числовой акцент, декор)],

      text(weight: "bold", fill: accent, size: fs-item, [Акцентное слово]),
        spec[Accent · красный D92B04 · одно слово на слайд],
    )
  })
})
