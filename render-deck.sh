#!/usr/bin/env bash
# Build a branded Serokell slide deck from a deck.md living ANYWHERE on disk.
#
#   ./render-deck.sh ~/talks/kickoff.md               -> ~/talks/kickoff.pdf
#   ./render-deck.sh ~/talks/kickoff.md /tmp/out.pdf  -> /tmp/out.pdf
#   THEME=dark ./render-deck.sh ~/talks/kickoff.md    -> dark palette
#
# This is the entry point used by the `serokell-slides` skill. Unlike
# build-deck.sh it does not require the deck to live in decks/, and it never
# writes inside the template directory - which matters when the template is
# installed read-only as a plugin. The work happens in a temp directory: the
# layout library and assets are copied in, the deck and its images alongside.
set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "error: $*" >&2; exit 1; }

if ! command -v typst >/dev/null 2>&1; then
  cat >&2 <<'EOF'
error: typst is not installed - it renders the PDF.
  macOS:  brew install typst
  Linux:  cargo install --locked typst-cli   (or your package manager)
  other:  https://github.com/typst/typst#installation
EOF
  exit 1
fi
command -v python3 >/dev/null 2>&1 || die "python3 is required (it builds the deck from deck.md)"

[ $# -ge 1 ] || die "usage: render-deck.sh <deck.md> [output.pdf]"

SRC="$1"
[ -f "$SRC" ] || die "no such deck: $SRC"
SRC="$(cd "$(dirname "$SRC")" && pwd)/$(basename "$SRC")"
SRC_DIR="$(dirname "$SRC")"

if [ $# -ge 2 ]; then
  OUT="$2"
else
  OUT="$SRC_DIR/$(basename "${SRC%.*}").pdf"
fi
mkdir -p "$(dirname "$OUT")"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp "$TEMPLATE_DIR/slides.typ" "$WORK/"
cp -R "$TEMPLATE_DIR/assets" "$WORK/assets"

# Copy across every local image the deck points at, keeping the relative path so
# `image=diagrams/x.png` still resolves inside the sandbox root.
while IFS= read -r ref; do
  case "$ref" in
    http://*|https://*|"") continue ;;
    /*) continue ;;   # absolute paths would escape the sandbox root
  esac
  if [ -f "$SRC_DIR/$ref" ]; then
    mkdir -p "$WORK/$(dirname "$ref")"
    cp "$SRC_DIR/$ref" "$WORK/$ref"
  elif [ ! -f "$WORK/$ref" ]; then   # may already be a template asset
    echo "warning: image not found, a grey placeholder will show instead: $ref" >&2
  fi
done < <(grep -ohE '[A-Za-z0-9_./-]+\.(png|jpg|jpeg|svg|webp|gif)' "$SRC" 2>/dev/null | sort -u || true)

# deck.md -> Typst (warnings about over-long text go to stderr and are real)
python3 "$TEMPLATE_DIR/slidegen.py" "$SRC" > "$WORK/deck.typ"

# theme (light|dark) from the deck.md frontmatter, or override with THEME=dark
theme="${THEME:-$(sed -n '/^---/,/^---/p' "$SRC" | grep -oiE '^theme:[[:space:]]*[a-z]+' | head -1 | grep -oiE '[a-z]+$' || true)}"
theme="${theme:-light}"

typst compile "$WORK/deck.typ" "$OUT" \
  --root "$WORK" \
  --font-path "$WORK/assets/fonts" \
  --ignore-system-fonts \
  --input "theme=${theme}"

# One page per slide. A slide with too much text is CLIPPED rather than split,
# so this catches the other failure: a layout that flowed onto a second page.
slides=$(grep -cE '^@[A-Za-z]' "$SRC" || true)
pages=$(python3 - "$OUT" <<'PY'
import re, sys
d = open(sys.argv[1], "rb").read()
c = [int(x) for x in re.findall(rb"/Count\s+(\d+)", d)]
print(max(c) if c else 0)
PY
)

echo "$OUT"
echo "(${slides} slides, ${pages} pages, theme ${theme})" >&2

if [ "$pages" != "$slides" ] && [ "$pages" != "0" ]; then
  echo "WARNING: ${slides} slides produced ${pages} pages - a slide overflowed onto a second page. Shorten it or split it in two." >&2
  exit 2
fi
