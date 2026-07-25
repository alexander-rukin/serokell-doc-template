#!/usr/bin/env bash
# Build a branded Serokell slide deck from an author-friendly deck.md.
#   ./build-deck.sh path/to/deck.md [out.pdf]
# The author only edits deck.md; this regenerates the PDF in seconds.
#
# Checks the environment first, then verifies that the PDF has exactly one page
# per slide - a slide that overflowed onto a second page is the one failure this
# pipeline can produce silently.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
md="${1:?usage: build-deck.sh deck.md [out.pdf]}"
out="${2:-${md%.md}.pdf}"

# ---- environment -------------------------------------------------------------
if ! command -v typst >/dev/null 2>&1; then
  cat >&2 <<'EOF'
typst is not installed - it renders the PDF.

  macOS:   brew install typst
  Linux:   cargo install --locked typst-cli   (or your package manager)
  Any OS:  download a binary from https://github.com/typst/typst/releases

Then rerun this command.
EOF
  exit 1
fi
command -v python3 >/dev/null 2>&1 || { echo "python3 is required (it builds the deck from deck.md)." >&2; exit 1; }
[ -f "${here}/src/slides.typ" ] || { echo "src/slides.typ not found next to build-deck.sh - run this script from a checkout of the template repo." >&2; exit 1; }
[ -d "${here}/assets/fonts" ] || { echo "assets/fonts is missing - the brand fonts live there; re-clone the repo." >&2; exit 1; }
[ -f "$md" ] || { echo "no such deck: $md" >&2; exit 1; }

# ---- generate + compile ------------------------------------------------------
# Generated Typst sits beside slides.typ so the #import resolves; asset paths
# in it are anchored at --root, which is the checkout.
gen="${here}/src/_$(basename "${md%.md}").typ"
python3 "${here}/src/slidegen.py" "$md" > "$gen"

# theme (light|dark) from the deck.md frontmatter, or override with THEME=dark
# (a deck with no frontmatter must still build - hence the `|| true`: with
# `pipefail` a non-matching grep would otherwise abort the script silently)
theme="${THEME:-$(sed -n '/^---/,/^---/p' "$md" | grep -oiE '^theme:[[:space:]]*[a-z]+' | head -1 | grep -oiE '[a-z]+$' || true)}"
theme="${theme:-light}"
case "$theme" in
  light|dark) ;;
  *) echo "error: theme must be light or dark, got '$theme'" >&2; exit 1 ;;
esac

typst compile \
  --font-path "${here}/assets/fonts" \
  --ignore-system-fonts \
  --root "${here}" \
  --input "theme=${theme}" \
  "$gen" "$out"

# ---- verify: one page per slide ---------------------------------------------
slides=$(python3 - "$here" "$md" <<'SLIDECOUNT'
import sys
sys.path.insert(0, sys.argv[1] + "/src")
import slidegen
print(len(slidegen.split_slides(open(sys.argv[2], encoding="utf-8").read())[1]))
SLIDECOUNT
)
pages=$(python3 - "$out" <<'PY'
import re, sys
d = open(sys.argv[1], "rb").read()
c = [int(x) for x in re.findall(rb"/Count\s+(\d+)", d)]
print(max(c) if c else 0)
PY
)

echo "built: $out  (${slides} slides, ${pages} pages, theme ${theme})"

if [ "$pages" != "$slides" ] && [ "$pages" != "0" ]; then
  cat >&2 <<EOF

WARNING: ${slides} slides produced ${pages} pages - a slide overflowed.
Find it (the page after a duplicate-looking one) and shorten that slide:
fewer bullets, shorter lines, or move half the content to a second slide.
EOF
  exit 2
fi
