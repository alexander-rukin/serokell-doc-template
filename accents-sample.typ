// Accent language sample - shows the ONE brand colour (red #D92B04) applied
// sparingly across layouts. One accent per slide. This is the vocabulary to
// agree on before rolling it across the whole deck.

#import "slides.typ": *

// 1. COVER - one key word in the title painted red.
#cover(
  [Один бренд, много #ac[форматов] слайда],
  subtitle: [Витрина раскладок с брендовыми акцентами],
  meta: [Демо-колода · акцентный язык · 24 июля 2026],
  tag: "cover",
)

// 2. SECTION - red accent bar as the section marker above the title (the number
// itself stays muted; the bar is the accent, like the cover). Sasha 24.07: a
// section slide with no accent has nothing to show.
#slide-raw(tag: "section", vblock(bigw, {
  accent-bar
  v(gap-bar)
  hd(fs-item, text(fill: ink-soft)[Раздел 01])
  v(gap-meta)
  disp(fs-title, [Раздел-разделитель])
}))

// 3. STATEMENT - accent word in the thought + a red-ruled footnote (noted).
#slide-raw(tag: "statement", vblock(bigw, {
  disp(fs-title, par(leading: lead-disp)[Одна мысль, набранная #ac[крупно] и~с~воздухом.])
  v(gap-title-sub)
  noted(bd(fs-item, [Сноска с красной полоской слева - для важной ремарки под мыслью.]))
}))

// 4. STAT - the big figure carries the accent.
#stat(
  [#ac[1] файл],
  [меняешь бренд - правишь одно место, и это едет по всей деке],
  tag: "stat",
)

// 5. QUOTE - accent only on the key words; no rule on the heading (Sasha 24.07:
// a red bar on a heading looked odd - accents on headings stay in the type).
#slide-raw(tag: "quote", vblock(bigw, {
  hd(fs-head, par(leading: lead-head)[«Самый убедительный пример вывода - это #ac[сам вывод].»])
  v(gap-title-sub)
  bd(fs-small, [слайд про эту деку], fill: ink-soft)
}))

// 6. BULLETS - accent word in the lead, one accented key item.
#bullets(
  [Список тезисов],
  (
    [Заголовок держит секцию.],
    [Акцент - на #ac[одном] слове.],
    [Один короткий тезис на строку.],
    [Ровный ритм, ничего не переполняет.],
  ),
  lead: [Красный - редкий #ac[акцент], не второй основной цвет.],
  tag: "bullets",
)
