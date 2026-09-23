#!/usr/bin/env bash
# Advisory checks on an author's Markdown, run as part of every build.
#
# These are hints, not errors. The script always exits 0 and never blocks the
# build, because every one of these can be deliberate. The point is that the
# common silent authoring mistakes become visible at build time instead of
# being discovered in the finished PDF.
#
# Usage: ./md-advice.sh path/to/document.md
set -uo pipefail

SRC="${1:-}"
[ -f "$SRC" ] || exit 0

hint() { printf 'hint: %s\n' "$1" >&2; }

# --- 1. Consecutive label lines that will merge ------------------------------
# Markdown joins adjacent lines into one paragraph, so a stack of
# "Location:" / "Work:" / "Languages:" lines becomes one run-on block.
# Only flagged when two consecutive lines both look like "Label: value",
# which is almost never meant to be prose.
awk '
  # String regexes, not /../ literals: a slash inside a bracket expression
  # terminates an awk regex literal.
  function is_label(s) {
    return (s ~ "^\\*\\*[^*]+:\\*\\*") || (s ~ "^[A-Z][A-Za-z /&-]*: ")
  }
  /^[ \t]*$/ { prev=""; next }
  /^[#>|`-]/ { prev=""; next }
  {
    if (prev != "" && is_label(prev) && is_label($0)) {
      if (!reported) { print NR; reported=1 }
    }
    prev=$0
  }
' "$SRC" | while read -r line; do
  hint "lines around $line will merge into one paragraph. Markdown joins"
  hint "  adjacent lines; put a blank line between each 'Label: value' so they"
  hint "  stack as separate lines."
done

# --- 2. Repeated identical headings -----------------------------------------
dupe=$(grep -E '^#{1,3} ' "$SRC" 2>/dev/null | sort | uniq -d | head -1 || true)
if [ -n "$dupe" ]; then
  hint "heading '${dupe}' is used more than once. Naming each one after what it"
  hint "  covers (a client, a phase) makes the document scannable."
fi

# --- 3. Long unbroken code spans in a table cell -----------------------------
# A code span with spaces in it (`vault = a + b`) still wraps fine inside a
# cell - Typst breaks it at the spaces, verified by rendering one. It is
# specifically an UNBROKEN token - a commit hash, a base58 address, nothing
# to break on - that moves as one solid pill and overflows the column instead.
# Walked with index()/substr() rather than a `{n,}` regex interval, which is
# not guaranteed available in every awk this runs under.
#
# Reports every offending row, not just the first: a document can have a
# short, harmless span on an early row and a genuinely overflowing one further
# down (e.g. a wide two-column metadata table followed by a narrow four-column
# one), and stopping at the first match would flag the harmless row while
# staying silent about the real one.
awk '
  /^\|/ && $0 !~ /<br>/ {
    line = $0
    hit = 0
    while ((i = index(line, "`")) > 0) {
      rest = substr(line, i + 1)
      j = index(rest, "`")
      if (j == 0) break
      tok = substr(rest, 1, j - 1)
      if (length(tok) >= 24 && tok !~ /[ \t]/) hit = 1
      line = substr(rest, j + 1)
    }
    if (hit) print NR
  }
' "$SRC" | while read -r line; do
  hint "line $line has a table cell with a long unbroken code span. It cannot"
  hint "  wrap and will overflow its column; split it with a manual <br>, e.g."
  hint "  \`AAAA1111bbbb2222\`<br>\`CCCC3333dddd4444\` - see the README's Tables"
  hint "  section."
done

exit 0
