#!/usr/bin/env bash
# Build a branded Serokell slide deck from an author-friendly deck.md.
#   ./build-deck.sh path/to/deck.md [out.pdf]
# The author only edits deck.md; this regenerates the PDF in seconds.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
md="${1:?usage: build-deck.sh deck.md [out.pdf]}"
out="${2:-${md%.md}.pdf}"

if [ ! -f "${here}/slides.typ" ]; then
  echo "slides.typ not found next to build-deck.sh (need the layout library)." >&2
  exit 1
fi

# Generated Typst sits beside slides.typ so the #import and assets/ resolve.
gen="${here}/_$(basename "${md%.md}").typ"
python3 "${here}/slidegen.py" "$md" > "$gen"

# theme (light|dark) from the deck.md frontmatter, or override with THEME=dark
theme="${THEME:-$(sed -n '/^---/,/^---/p' "$md" | grep -oiE '^theme:[[:space:]]*[a-z]+' | head -1 | grep -oiE '[a-z]+$')}"
theme="${theme:-light}"

typst compile \
  --font-path "${here}/assets/fonts" \
  --ignore-system-fonts \
  --root "${here}" \
  --input "theme=${theme}" \
  "$gen" "$out"

echo "built: $out"
