#!/usr/bin/env bash
# Test suite for the template: documents, decks, and the failure modes that are
# silent here - a layout the author surface cannot reach, text clipped instead of
# reflowed, a deck that builds only because it happens to have frontmatter.
#
#   ./test.sh            run everything
#
# Exits non-zero on the first real failure. Everything is written to a temp
# directory; the repository is left untouched (that is itself one of the tests).
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
cd "$here"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

pass=0; fail=0
ok()   { printf '  ok    %s\n' "$1"; pass=$((pass + 1)); }
bad()  { printf '  FAIL  %s\n' "$1"; [ -n "${2:-}" ] && printf '        %s\n' "$2"; fail=$((fail + 1)); }
head_() { printf '\n%s\n' "$1"; }

command -v typst >/dev/null 2>&1 || { echo "typst is not installed - cannot run the suite." >&2; exit 1; }

# ---------------------------------------------------------------- documents
head_ "Documents (render.sh)"
for f in content/*.md; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  if out=$(./render.sh "$f" "$WORK/doc-${name%.md}.pdf" 2>&1); then
    [ -s "$WORK/doc-${name%.md}.pdf" ] && ok "$name" || bad "$name" "empty PDF"
  else
    bad "$name" "$(echo "$out" | tail -2)"
  fi
done

# -------------------------------------------------------------------- decks
head_ "Decks (render-deck.sh), one page per slide, no length warnings"
for f in decks/*.md; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  err="$WORK/${name}.err"
  if ./render-deck.sh "$f" "$WORK/deck-${name%.md}.pdf" >/dev/null 2>"$err"; then
    if grep -q '^warning:' "$err"; then
      bad "$name" "length warnings: $(grep -c '^warning:' "$err") (text would be clipped)"
    else
      ok "$name ($(grep -oE '[0-9]+ slides' "$err" | head -1))"
    fi
  else
    bad "$name" "$(tail -2 "$err")"
  fi
done

head_ "Dark theme"
if THEME=dark ./render-deck.sh decks/all-layouts.md "$WORK/dark.pdf" >/dev/null 2>"$WORK/dark.err"; then
  ok "all-layouts renders dark"
else
  bad "all-layouts dark" "$(tail -2 "$WORK/dark.err")"
fi

# ------------------------------------------------- the catalog stays in sync
head_ "Catalog coverage"
tags_known=$(python3 -c "
import sys; sys.path.insert(0, '$here')
import slidegen
print('\n'.join(sorted(slidegen.LAYOUTS)))
")
tags_shown=$(grep -oE '^@[a-z0-9-]+' decks/all-layouts.md | sed 's/^@//' | sort -u)
missing=$(comm -23 <(echo "$tags_known") <(echo "$tags_shown"))
if [ -z "$missing" ]; then
  ok "every layout appears in decks/all-layouts.md ($(echo "$tags_known" | wc -l | tr -d ' ') layouts)"
else
  bad "layouts missing from all-layouts.md" "$(echo "$missing" | tr '\n' ' ')"
fi

# every layout the generator emits must exist in the library
undefined=""
while IFS= read -r fn; do
  grep -qE "^#let ${fn}\(" slides.typ || undefined="$undefined $fn"
done < <(grep -ohE '"#[a-z0-9-]+\(' slidegen.py | sed 's/"#//; s/($//; s/(//' | sort -u)
if [ -z "$undefined" ]; then
  ok "every emitted call exists in slides.typ"
else
  bad "generator calls layouts slides.typ does not define" "$undefined"
fi

# ------------------------------------------------------------ error handling
head_ "Errors are explained, not silent"

printf '@nope\n# x\n' > "$WORK/bad-layout.md"
out=$(./render-deck.sh "$WORK/bad-layout.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "unknown layout"; then
  ok "unknown layout is rejected by name"
else
  bad "unknown layout" "rc=$rc out=$(echo "$out" | tail -1)"
fi

printf '@venn\n# Heading\n- A\n- B\n- C\n' > "$WORK/bad-field.md"
out=$(./render-deck.sh "$WORK/bad-field.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "needs a 'desc:' line"; then
  ok "a missing required field names the field"
else
  bad "missing field" "rc=$rc out=$(echo "$out" | tail -1)"
fi

printf '@compare\n# Heading\n- only one item | body\n' > "$WORK/bad-count.md"
out=$(./render-deck.sh "$WORK/bad-count.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "expects 2 items"; then
  ok "a wrong item count says how many are expected"
else
  bad "item count" "rc=$rc out=$(echo "$out" | tail -1)"
fi

# ------------------------------------------------- the silent failures proper
head_ "Silent failure modes"

{ echo '@split'; echo '# Overflowing slide'
  for i in $(seq 1 30); do echo "Paragraph $i, long enough to run past the bottom of a fixed-height slide frame."; echo; done
} > "$WORK/overflow.md"
out=$(./render-deck.sh "$WORK/overflow.md" "$WORK/x.pdf" 2>&1)
if echo "$out" | grep -q '^warning:.*holds about'; then
  ok "text past the frame is reported before the PDF is opened"
else
  bad "overflow budget" "no warning for a 2000-char body"
fi

printf '@code\n# Showing the format itself\n```md\n@compare\n# Sample\n- A | one\n- B | two\n```\n' > "$WORK/fence.md"
if ./render-deck.sh "$WORK/fence.md" "$WORK/fence.pdf" >/dev/null 2>"$WORK/fence.err" \
   && [ "$(python3 -c "
import re
d = open('$WORK/fence.pdf','rb').read()
print(max(int(x) for x in re.findall(rb'/Count\s+(\d+)', d)))")" = "1" ]; then
  ok "a @tag inside a code fence stays sample text, not a new slide"
else
  bad "code fence" "$(tail -2 "$WORK/fence.err")"
fi

printf '@statement\n# A deck with no frontmatter\n' > "$WORK/no-fm.md"
if ./render-deck.sh "$WORK/no-fm.md" "$WORK/nofm.pdf" >/dev/null 2>&1 && [ -s "$WORK/nofm.pdf" ]; then
  ok "a deck without frontmatter still builds"
else
  bad "no frontmatter" "the theme lookup aborted the build"
fi

# ------------------------------------------- read-only install compatibility
head_ "Nothing is written inside the template"
mkdir -p "$WORK/elsewhere"
cp assets/sample-photo.jpg "$WORK/elsewhere/pic.jpg"
printf '@split image=pic.jpg\n# From another directory\nThe image sits next to the deck.\n' > "$WORK/elsewhere/deck.md"
before=$(git status --porcelain | sort)
if ./render-deck.sh "$WORK/elsewhere/deck.md" >/dev/null 2>&1 && [ -s "$WORK/elsewhere/deck.pdf" ]; then
  ok "a deck outside the repo builds, PDF lands next to it"
else
  bad "external deck" "did not produce $WORK/elsewhere/deck.pdf"
fi
after=$(git status --porcelain | sort)
if [ "$before" = "$after" ]; then
  ok "the working tree is unchanged by a build"
else
  bad "build dirtied the repository" "$(diff <(echo "$before") <(echo "$after") | head -3 | tr '\n' ' ')"
fi

# --------------------------------------------------------------------- done
printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
