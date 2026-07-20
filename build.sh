#!/usr/bin/env bash
# Build a branded PDF from a Markdown file in content/.
#
#   ./build.sh example-proposal        -> out/example-proposal.pdf
#   ./build.sh content/foo.md          -> out/foo.pdf
#   ./build.sh example-proposal --watch
#
# Kept dependency-free and CLI-driven on purpose: the same invocation is what
# the phase-2 sandbox service will shell out to.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

if ! command -v typst >/dev/null 2>&1; then
  echo "error: typst is not installed." >&2
  echo "  macOS:  brew install typst" >&2
  echo "  other:  https://github.com/typst/typst#installation" >&2
  exit 1
fi

if [ $# -lt 1 ]; then
  echo "usage: ./build.sh <document> [--watch]" >&2
  echo "" >&2
  echo "available documents:" >&2
  for f in content/*.md; do
    [ -e "$f" ] || continue
    echo "  $(basename "${f%.md}")" >&2
  done
  exit 2
fi

DOC="$1"
shift

# Accept a bare name, a path, and with or without the .md extension.
case "$DOC" in
  */*) SRC="$DOC" ;;
  *)   SRC="content/$DOC" ;;
esac
[ "${SRC%.md}" = "$SRC" ] && SRC="$SRC.md"

if [ ! -f "$SRC" ]; then
  echo "error: no such document: $SRC" >&2
  exit 1
fi

NAME="$(basename "${SRC%.md}")"
OUT="out/$NAME.pdf"
mkdir -p out

# The template degrades to a placeholder rather than failing when the footer
# artwork is absent, so tell it which case we are in.
if [ -f assets/footer-mountains-left.png ] && [ -f assets/footer-mountains-right.png ]; then
  ART=true
else
  ART=false
  echo "warning: footer artwork missing from assets/ - building with a placeholder." >&2
fi

# --watch rebuilds on every save; anything else is a one-shot compile.
CMD=compile
if [ "${1:-}" = "--watch" ]; then
  CMD=watch
fi

typst "$CMD" main.typ "$OUT" \
  --root . \
  --font-path assets/fonts \
  --ignore-system-fonts \
  --input "doc=$SRC" \
  --input "art=$ART"

if [ "$CMD" = "compile" ]; then
  echo "built $OUT"
fi
