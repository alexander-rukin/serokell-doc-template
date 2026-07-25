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

mkdir -p "$WORK/src"
cp "$TEMPLATE_DIR/src/slides.typ" "$WORK/src/"
# Everything Typst reads through --root has to be inside the sandbox, so the
# brand artwork is copied. Fonts are not: --font-path is free to point outside
# it, and 6.5MB of typefaces per build is worth not copying.
mkdir -p "$WORK/assets"
find "$TEMPLATE_DIR/assets" -maxdepth 1 -type f -exec cp {} "$WORK/assets/" \;

# The images to bring into the sandbox come from the generator, not from a grep
# over deck.md. Grepping matched anything that merely LOOKED like a filename -
# a shell command inside a ```-fence, a path named in a sentence - and then died
# on it; and it missed real ones whose names hold spaces, capitals or Cyrillic.
# The generator knows which strings it actually passed to a layout.
SRC_REAL="$(cd "$SRC_DIR" && pwd -P)"
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  # already in the sandbox: a template asset such as assets/sample-photo.jpg
  [ -f "$WORK/$ref" ] && continue
  case "$ref" in
    http://*|https://*) continue ;;
    # Anything that could resolve outside the sandbox root. An absolute path is
    # obvious; `../` is not, and without this a deck handed to you by someone
    # else could write through `cp` to any path you can write - the sandbox is
    # what keeps a build from touching the rest of the disk.
    /*)   die "image path must stay inside the deck's folder: $ref" ;;
    ..*|*/..*) die "image path must stay inside the deck's folder: $ref" ;;
  esac
  # A symlink next to the deck can still point anywhere, so resolve before
  # copying. Both sides are compared physically (`pwd -P`, `readlink -f`), or a
  # deck reached through a symlinked parent - every path under /tmp on macOS -
  # would look like an escape.
  real="$(cd "$SRC_DIR" 2>/dev/null && readlink -f "$ref" 2>/dev/null || true)"
  case "$real" in
    "$SRC_REAL"/*) ;;
    "") ;;                       # does not resolve - reported as missing below
    *) die "image resolves outside the deck's folder: $ref -> $real" ;;
  esac
  [ -f "$SRC_DIR/$ref" ] || die "image not found next to the deck: $ref
  put the file at $SRC_DIR/$ref, or leave the image off that slide for a placeholder"
  mkdir -p "$WORK/$(dirname "$ref")"
  cp "$SRC_DIR/$ref" "$WORK/$ref"
done < <(python3 "$TEMPLATE_DIR/src/slidegen.py" --images "$SRC")

# deck.md -> Typst (warnings about over-long text go to stderr and are real)
python3 "$TEMPLATE_DIR/src/slidegen.py" "$SRC" > "$WORK/src/deck.typ"

# theme (light|dark) from the deck.md frontmatter, or override with THEME=dark
theme="${THEME:-$(sed -n '/^---/,/^---/p' "$SRC" | grep -oiE '^theme:[[:space:]]*[a-z]+' | head -1 | grep -oiE '[a-z]+$' || true)}"
theme="${theme:-light}"
case "$theme" in
  light|dark) ;;
  *) echo "error: theme must be light or dark, got '$theme'" >&2; exit 1 ;;
esac

typst compile "$WORK/src/deck.typ" "$OUT" \
  --root "$WORK" \
  --font-path "$TEMPLATE_DIR/assets/fonts" \
  --ignore-system-fonts \
  --input "theme=${theme}"

# One page per slide. A slide with too much text is CLIPPED rather than split,
# so this catches the other failure: a layout that flowed onto a second page.
slides=$(python3 - "$TEMPLATE_DIR" "$SRC" <<'SLIDECOUNT'
import sys
sys.path.insert(0, sys.argv[1] + "/src")
import slidegen
print(len(slidegen.split_slides(open(sys.argv[2], encoding="utf-8").read())[1]))
SLIDECOUNT
)
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
