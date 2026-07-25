// Type scale specimen - the PROPOSED clean hierarchy. Six fixed text roles,
// each shown at its real size with a spec label saying exactly where it is used.
// One role per job, one job per role - no more "subhead" drifting 15/12/9.6pt.

#import "../../slides.typ": *

#slide-raw(tag: "type-scale", {
  at(16.9, 16.9, 209.6, hd(fs-head, [Type scale - six roles]))
  at(16.9, 38, CW / 1mm, {
    let spec(t) = text(font: font-mono, size: fs-small, fill: ink-soft, t)
    grid(columns: (98mm, 1fr), column-gutter: 8mm, row-gutter: 6.5mm, align: horizon,

      disp(fs-title, [Headline]),
        spec[H1 · Hero · 36.6pt · Bold · cover, section, big statement, figure],

      hd(fs-head, [Heading]),
        spec[H2 · Heading · 18.8pt · Bold · slide heading, pull quote],

      text(font: font-heading, size: fs-item, weight: "bold", fill: ink, [Label]),
        spec[H3 · Label · 15pt · Bold · column and card label (rare)],

      text(font: font-body, size: fs-item, weight: "medium", fill: ink, [Subhead]),
        spec[Subhead · 15pt · Medium · the one explanatory line under H1/H2],

      bd(fs-desc, [Body text]),
        spec[Body · 12pt · Regular · items, descriptions, card body],

      bd(fs-small, [Caption and attribution], fill: ink-soft),
        spec[Caption · 9.6pt · Regular · footnote, attribution, meta, axis],

      text(font: font-display, size: fs-lead2, weight: "bold", fill: ink, [1]),
        spec[Figure · 23.4pt · Bold · step number (numeric accent, decorative)],

      text(weight: "bold", fill: accent, size: fs-item, [Accent word]),
        spec[Accent · red D92B04 · one word per slide],
    )
  })
})
