# Specimens

Not part of the product. Two Typst files for whoever edits the brand:

- `typescale.typ` - every type size in the scale, on one page, so a proposed
  change can be seen next to what it replaces.
- `weights.typ` - the available font weights, same idea.

Render either from the repository root:

```sh
typst compile dev/specimens/typescale.typ --root . --font-path assets/fonts --ignore-system-fonts
```

Layout exploration does not live here. It lives in git history: the slide
library went through nine background-artwork iterations and a set of cover
variants before `src/slides.typ` settled, and keeping those files at the repo root
made a template look like someone's sketchbook.
