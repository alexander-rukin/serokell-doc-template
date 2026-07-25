#let accent   = rgb("#D92B04")
#let bg       = white
#let ink      = rgb("#1A1A1A")
#let ink-soft = rgb("#5A5F66")
#let font-display = ("Google Sans Flex 120pt", "Golos Text")
#let font-heading = ("Google Sans Flex 36pt", "Golos Text")
#let font-body    = ("Google Sans Flex 24pt", "Golos Text")
#let W  = 254mm
#let H  = 142.875mm
#let MX  = 18mm
#let TOP = 22mm
#let BOT = 9mm
#let bar-w = 16mm
#let bar-h = 3pt
#let accent-bar = box(width: bar-w, height: bar-h, fill: accent)
#let MEASURE = 172mm
#let mtn = "assets/brand-mountains.png"
#let peak = "assets/brand-peak.png"

#let title-block = {
  accent-bar
  v(9mm)
  text(font: font-display, size: 34pt, weight: "semibold", fill: ink)[#par(leading: 0.3em, box(width: MEASURE)[Serokell slide system])]
  v(6mm)
  text(font: font-heading, size: 15pt, fill: ink-soft)[#par(leading: 0.5em, box(width: MEASURE)[Витрина раскладок - один бренд, много форматов слайда])]
  v(5mm)
  text(font: font-body, size: 10.5pt, fill: ink-soft)[Демо-колода · вариант расположения гор]
}

#let band(strip) = place(bottom + left, dx: -MX, dy: BOT,
  box(width: W, height: strip, clip: true,
    image(mtn, width: W, height: strip, fit: "cover")))

#let tag(n) = place(top + right, dx: MX, dy: -TOP + 2mm,
  text(font: font-body, size: 9pt, fill: ink-soft, weight: "medium", n))

#let slide(art, label) = page(width: W, height: H,
  margin: (x: MX, top: TOP, bottom: BOT), fill: bg, {
    art
    title-block
    tag(label)
  })

// 1. Wide band, bottom edge (34mm)
#slide(band(34mm), "1  широкая полоса снизу")

// 2. Thin band, bottom edge (18mm)
#slide(band(18mm), "2  тонкая полоса снизу")

// 3. Single peak, bottom-right corner (big)
#slide(place(bottom + right, dx: MX, dy: BOT, image(peak, width: 100mm)), "3  пик в правом нижнем углу")

// 4. Single peak, bottom-left corner
#slide(place(bottom + left, dx: -MX, dy: BOT, image(peak, width: 92mm)), "4  пик в левом нижнем углу")

// 5. Single peak, top-right corner (smaller)
#slide(place(top + right, dx: MX, dy: -TOP, image(peak, width: 64mm)), "5  пик в правом верхнем углу")

// 6. Wide band + single peak rising on the right, MIRRORED so the abrupt image
// edge falls off the right margin and the natural slope faces into the slide.
#slide({
  band(34mm)
  place(bottom + right, dx: MX, dy: BOT, scale(x: -100%, reflow: false, image(peak, width: 92mm)))
}, "6  полоса + пик справа (зеркало)")

// 7. Same, larger mirrored peak
#slide({
  band(34mm)
  place(bottom + right, dx: MX, dy: BOT, scale(x: -100%, reflow: false, image(peak, width: 115mm)))
}, "7  полоса + крупный пик справа (зеркало)")
