// Subhead treatment: two ways to keep it distinct from Body without them reading
// as "two thin levels". A - give it weight (Medium) => 3 weights on screen.
// B - keep it Regular but mute the colour => 2 weights, subhead differs by colour.

#import "../../src/slides.typ": *

#slide-raw(tag: "weights", {
  at(16.9, 16.9, 209.6, hd(fs-head, [Subhead: two ways to separate it from body text]))

  // Variant A - Medium (3 weights)
  at(16.9, 46, 100, {
    cap[OPTION A - Medium subhead]
    v(6mm)
    hd(fs-head, [Slide heading])
    v(gap-head-body)
    subh([Medium subhead - heavier than body, full black.])
    v(gap-head-body)
    bd(fs-desc, [Body text follows in the regular weight. Three weights on screen: Bold, Medium, Regular.])
  })

  // Variant B - Regular muted (2 weights)
  at(128.1, 46, 100, {
    cap[OPTION B - Regular muted subhead]
    v(6mm)
    hd(fs-head, [Slide heading])
    v(gap-head-body)
    text(font: font-body, size: fs-item, fill: ink-soft,
      [Regular subhead, separated by colour instead.])
    v(gap-head-body)
    bd(fs-desc, [Body text follows in the regular weight. Two weights only: Bold and Regular, with colour separating the subhead.])
  })
})
