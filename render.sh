#!/usr/bin/env bash
# Build a branded PDF from any Markdown file, anywhere on disk.
#
#   ./render.sh ~/notes/proposal.md              -> ~/notes/proposal.pdf
#   ./render.sh ~/notes/proposal.md /tmp/out.pdf -> /tmp/out.pdf
#
# This is the entry point used by the `serokell-pdf` skill. Unlike build.sh it
# does not require the document to live in content/, and it never writes inside
# the template directory, which matters when the template is installed read-only
# as a plugin.
#
# Typst restricts file access to a single --root tree, and the document and the
# template generally live in different places. So the work happens in a temp
# directory: the template is copied in, the document is copied in as
# content/doc.md, and any images the document references are copied alongside it
# with their relative paths preserved.
set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "error: $*" >&2; exit 1; }

if ! command -v typst >/dev/null 2>&1; then
  echo "error: typst is not installed." >&2
  echo "  macOS:  brew install typst" >&2
  echo "  other:  https://github.com/typst/typst#installation" >&2
  exit 1
fi

[ $# -ge 1 ] || die "usage: render.sh <document.md> [output.pdf]"

SRC="$1"
[ -f "$SRC" ] || die "no such file: $SRC"
SRC="$(cd "$(dirname "$SRC")" && pwd)/$(basename "$SRC")"
SRC_DIR="$(dirname "$SRC")"

if [ $# -ge 2 ]; then
  OUT="$2"
else
  OUT="$SRC_DIR/$(basename "${SRC%.*}").pdf"
fi
mkdir -p "$(dirname "$OUT")"

# Advisory checks on the author's Markdown. Hints only; never blocks the build.
[ -x "$TEMPLATE_DIR/md-advice.sh" ] && "$TEMPLATE_DIR/md-advice.sh" "$SRC"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp "$TEMPLATE_DIR/template.typ" "$TEMPLATE_DIR/main.typ" "$WORK/"
cp -R "$TEMPLATE_DIR/assets" "$WORK/assets"

mkdir -p "$WORK/content"
cp "$SRC" "$WORK/content/doc.md"

# Copy across every local image the document points at, keeping the path the
# Markdown uses so ![](diagrams/x.svg) still resolves.
while IFS= read -r ref; do
  case "$ref" in
    http://*|https://*|data:*|"") continue ;;
    # Anything that could resolve outside the sandbox root. An absolute path is
    # obvious; `../` is not, and without this a document handed to you by
    # someone else could write through `cp` to any path you can write - the
    # sandbox is what keeps a build from touching the rest of the disk.
    /*)   die "image path must stay inside the document's folder: $ref" ;;
    ..*|*/..*) die "image path must stay inside the document's folder: $ref" ;;
  esac
  # A symlink (or a symlinked folder) next to the document can still point anywhere;
  # resolve before copying so what lands in the PDF is a file from the document's own
  # folder and not, say, something out of a home directory.
  real="$(cd "$SRC_DIR" 2>/dev/null && readlink -f "$ref" 2>/dev/null || true)"
  case "$real" in
    "$SRC_DIR"/*) ;;
    "") ;;                       # does not resolve - handled as missing below
    *) die "image resolves outside the document's folder: $ref -> $real" ;;
  esac
  if [ -f "$SRC_DIR/$ref" ]; then
    mkdir -p "$WORK/content/$(dirname "$ref")"
    cp "$SRC_DIR/$ref" "$WORK/content/$ref"
  else
    # Stopping here beats "skipping" followed by a Typst failure naming a temp
    # directory this script has already deleted.
    die "image not found next to the document: $ref
  put the file at $SRC_DIR/$ref, or take the ![...](...) out of the markdown"
  fi
done < <(grep -oE '!\[[^]]*\]\([^)]+\)' "$SRC" 2>/dev/null \
           | sed -E 's/.*\(([^)]+)\).*/\1/' | sed -E 's/[[:space:]]+".*"$//' || true)

if [ -f "$WORK/assets/footer-mountains-left.png" ] \
   && [ -f "$WORK/assets/footer-mountains-right.png" ]; then
  ART=true
else
  ART=false
  echo "warning: footer artwork missing - building with a placeholder." >&2
fi

typst compile "$WORK/main.typ" "$OUT" \
  --root "$WORK" \
  --font-path "$WORK/assets/fonts" \
  --ignore-system-fonts \
  --input "doc=content/doc.md" \
  --input "art=$ART"

echo "$OUT"
