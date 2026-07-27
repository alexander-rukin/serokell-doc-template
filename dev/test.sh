#!/usr/bin/env bash
# Test suite for the template: documents, decks, and the failure modes that are
# silent here - a layout the author surface cannot reach, text clipped instead of
# reflowed, a deck that builds only because it happens to have frontmatter.
#
#   ./dev/test.sh        run everything
#
# Runs everything, prints a pass/fail line per check, exits non-zero at the end
# if any failed. Everything is written to a temp directory; the repository is
# left untouched (that is itself one of the checks).
set -uo pipefail

# The suite drives the entry points as a user would, from the repo root.
here="$(cd "$(dirname "$0")/.." && pwd)"
cd "$here"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

STAMP="$WORK/.stamp"
: > "$STAMP"          # reference mtime: nothing in the repo may be newer at the end

pass=0; fail=0
ok()   { printf '  ok    %s\n' "$1"; pass=$((pass + 1)); }
bad()  { printf '  FAIL  %s\n' "$1"; [ -n "${2:-}" ] && printf '        %s\n' "$2"; fail=$((fail + 1)); }
skip_() { printf '  skip  %s\n' "$1"; }
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
    if grep -q 'holds about' "$err"; then
      bad "$name" "length warnings: $(grep -c 'holds about' "$err") (text would be clipped)"
    else
      ok "$name ($(grep -oE '[0-9]+ slides' "$err" | head -1))"
    fi
  else
    bad "$name" "$(tail -2 "$err")"
  fi
done

head_ "Dark theme"
# Compiling is not the claim - the claim is that the page comes out dark. A
# check that only asserts "typst exited 0" passes even with the theme wired to
# a constant, which is what this one used to do.
if THEME=dark ./render-deck.sh decks/all-layouts.md "$WORK/dark.pdf" >/dev/null 2>"$WORK/dark.err" \
   && THEME=light ./render-deck.sh decks/all-layouts.md "$WORK/light.pdf" >/dev/null 2>&1; then
  lum() {
    rm -f "$WORK"/lum-*.png
    # pdftoppm zero-pads the page number to the document's width, so glob it
    pdftoppm -png -r 20 -f 2 -l 2 "$1" "$WORK/lum" 2>/dev/null
    python3 - "$WORK" <<'LUM'
import glob, sys
from PIL import Image
f = sorted(glob.glob(sys.argv[1] + "/lum-*.png"))[0]
im = Image.open(f).convert("L")
print(round(sum(im.getdata()) / (im.width * im.height)))
LUM
  }
  d=$(lum "$WORK/dark.pdf"); l=$(lum "$WORK/light.pdf")
  if [ "$d" -lt 90 ] && [ "$l" -gt 180 ]; then
    ok "the dark deck is actually dark (page luminance $d vs $l light)"
  else
    bad "dark theme" "page luminance dark=$d light=$l - the theme is not reaching the page"
  fi
else
  bad "all-layouts dark" "$(tail -2 "$WORK/dark.err")"
fi

head_ "Theme values"
if out=$(THEME=bogus ./render-deck.sh decks/plugin-deck.md "$WORK/x.pdf" 2>&1); rc=$?; [ $rc -ne 0 ] \
   && echo "$out" | grep -q "theme must be light or dark"; then
  ok "an unknown theme is refused, not silently rendered light"
else
  bad "theme validation" "rc=$rc out=$(echo "$out" | tail -1)"
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
  grep -qE "^#let ${fn}\(" src/slides.typ || undefined="$undefined $fn"
done < <(grep -ohE '"#[a-z0-9-]+\(' src/slidegen.py | sed 's/"#//; s/($//; s/(//' | sort -u)
if [ -z "$undefined" ]; then
  ok "every emitted call exists in src/slides.typ"
else
  bad "generator calls layouts src/slides.typ does not define" "$undefined"
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

head_ "build-deck.sh (the path a cloned repo takes)"
# It writes inside the checkout, has its own theme lookup and page-count guard,
# and nothing else in this suite touches it.
if out=$(./build-deck.sh decks/plugin-deck.md "$WORK/bd.pdf" 2>&1) && [ -s "$WORK/bd.pdf" ]; then
  if echo "$out" | grep -q '8 slides, 8 pages'; then
    ok "builds a deck and counts its pages"
  else
    bad "build-deck.sh page count" "$(echo "$out" | tail -1)"
  fi
else
  bad "build-deck.sh" "$(echo "$out" | tail -2)"
fi
rm -f src/_plugin-deck.typ

head_ "Author mistakes that used to crash or corrupt the build"

printf '@statement\n# Q3 // Q4 and/or later\n' > "$WORK/slashes.md"
if ./render-deck.sh "$WORK/slashes.md" "$WORK/slashes.pdf" >/dev/null 2>&1 \
   && pdftotext "$WORK/slashes.pdf" - 2>/dev/null | grep -q 'Q3 // Q4'; then
  ok "'//' in author text stays text (it opens a Typst comment)"
else
  bad "double slash" "the deck failed to build or the text was swallowed"
fi

printf '@team perrow=two\n# T\n- A | role\n- B | role\n' > "$WORK/badnum.md"
out=$(./render-deck.sh "$WORK/badnum.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "must be a whole number"; then
  ok "a non-numeric option is explained, not a Python traceback"
else
  bad "numeric option" "rc=$rc out=$(echo "$out" | tail -1)"
fi

printf 'Just prose, no layout tag anywhere\n' > "$WORK/notag.md"
out=$(./render-deck.sh "$WORK/notag.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "must start with a layout tag"; then
  ok "a deck with no tag says so, instead of guessing a layout"
else
  bad "no tag" "rc=$rc out=$(echo "$out" | tail -1)"
fi

printf '@image-row\n# Screens\n- nope.png | One | first\n- gone.png | Two | second\n' > "$WORK/norow.md"
out=$(./render-deck.sh "$WORK/norow.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "image not found next to the deck"; then
  ok "a layout that passes its images positionally is checked too"
else
  bad "image-row missing image" "rc=$rc out=$(echo "$out" | tail -1)"
fi

printf '@code\n# Showing an img: line\n```typ\n#split([T], [B], img: "diagram.png")\n```\n' > "$WORK/fenceimg.md"
if ./render-deck.sh "$WORK/fenceimg.md" "$WORK/fenceimg.pdf" >/dev/null 2>&1; then
  ok "an image path inside a code fence is sample text, not a file to find"
else
  bad "fenced img:" "a slide documenting the format failed to build"
fi

printf '# Doc\n\n![x](nope.png)\n\nText.\n' > "$WORK/docimg.md"
out=$(./render.sh "$WORK/docimg.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "image not found next to the document"; then
  ok "a document with a missing image stops with the filename"
else
  bad "document missing image" "rc=$rc out=$(echo "$out" | tail -1)"
fi

printf '@statement\n# Links\nsub: Docs at https://serokell.io/blog now\n' > "$WORK/url.md"
if ./render-deck.sh "$WORK/url.md" "$WORK/url.pdf" >/dev/null 2>&1 \
   && python3 -c "
import re, sys
d = open('$WORK/url.pdf','rb').read()
sys.exit(0 if b'serokell.io/blog' in b' '.join(re.findall(rb'/URI\s*\((.*?)\)', d)) else 1)"; then
  ok "a URL on a slide is still a link in the PDF"
else
  bad "url link" "the link annotation was lost (over-eager escaping?)"
fi

printf '@split image=nope.png\n# T\nBody\n' > "$WORK/noimg.md"
out=$(./render-deck.sh "$WORK/noimg.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "image not found next to the deck"; then
  ok "a missing image names the file, not a temp path"
else
  bad "missing image" "rc=$rc out=$(echo "$out" | tail -1)"
fi

head_ "Documents: both ways markdown names an image"
mkdir -p "$WORK/doc"
cp assets/sample-photo.jpg "$WORK/doc/pic.jpg"
printf '# Doc\n\n![alt][p]\n\nText.\n\n[p]: pic.jpg\n' > "$WORK/doc/ref.md"
if ./render.sh "$WORK/doc/ref.md" "$WORK/ref.pdf" >/dev/null 2>&1 && [ -s "$WORK/ref.pdf" ]; then
  ok "a reference-style ![alt][id] image is found"
else
  bad "reference-style image" "only inline ![](x) was collected"
fi

printf '# Doc\n\nText.\n\n```md\n![x](/etc/foo.png)\n```\n' > "$WORK/doc/fenced.md"
if ./render.sh "$WORK/doc/fenced.md" "$WORK/fenced.pdf" >/dev/null 2>&1; then
  ok "an image path inside a fenced example is not fetched"
else
  bad "fenced path in document" "a code sample aborted the build"
fi

head_ "The accent span"
printf '@statement\n# A headline with *one red span*\nA line beneath it\n' > "$WORK/acc.md"
out=$(python3 src/slidegen.py "$WORK/acc.md" 2>"$WORK/acc.err")
if echo "$out" | grep -q '#ac\[one red span\]' && [ ! -s "$WORK/acc.err" ]; then
  ok "*a span* becomes the brand accent"
else
  bad "accent span" "$(echo "$out" | tail -1) / $(cat "$WORK/acc.err")"
fi

printf '@split\n# Five times three is 5 * 3\nAnd a lone * character\n' > "$WORK/star.md"
if ! python3 src/slidegen.py "$WORK/star.md" 2>/dev/null | grep -q '#ac\['; then
  ok "an unpaired asterisk stays a literal character"
else
  bad "lone asterisk" "it was read as markup"
fi

printf '@bullets\n# A *marked* headline\nlead: and *another* one\n- x | y\n' > "$WORK/two.md"
if python3 src/slidegen.py "$WORK/two.md" 2>&1 >/dev/null | grep -q "2 accented spans"; then
  ok "two spans on one slide are called out"
else
  bad "two accents" "no warning - the one-per-slide rule is unenforced"
fi

# the markers are markup; counting them against the layout's budget would warn
# on text that fits - @statement holds 110, so a 110-char headline plus its two
# asterisks is exactly the case that used to trip
long=$(printf 'x%.0s' $(seq 1 110))
printf '@statement\n# *%s*\n' "$long" > "$WORK/budget.md"
if ! python3 src/slidegen.py "$WORK/budget.md" 2>&1 >/dev/null | grep -q "chars"; then
  ok "the asterisks do not count against the length budget"
else
  bad "accent vs budget" "markers were measured as text"
fi

head_ "Cyrillic lands on the bundled face, not on a stand-in"
# Google Sans Flex has no Cyrillic, so every font stack ends with Golos Text.
# Miss that entry in one of the two templates and Typst quietly substitutes its
# own default serif: the page still builds and still looks deliberate, which is
# why this needs a test rather than an eye.
if command -v pdffonts >/dev/null 2>&1; then
  printf '# %s\n\n%s\n' "Заголовок" "Абзац на русском." > "$WORK/cyr.md"
  printf '@statement\n# %s\n%s\n' "Заголовок" "Абзац на русском." > "$WORK/cyr-deck.md"
  for pair in "render.sh cyr document" "render-deck.sh cyr-deck deck"; do
    set -- $pair
    if ./"$1" "$WORK/$2.md" "$WORK/$2.pdf" >/dev/null 2>&1 \
       && pdffonts "$WORK/$2.pdf" | grep -qi golos \
       && ! pdffonts "$WORK/$2.pdf" | grep -qiE 'libertinus|deja ?vu|liberation|noto serif'; then
      ok "a Cyrillic $3 sets in Golos Text"
    else
      bad "Cyrillic in a $3" "$(pdffonts "$WORK/$2.pdf" 2>&1 | tail -3)"
    fi
  done
else
  skip_ "pdffonts is not installed - cannot check which faces were embedded"
fi

head_ "A deck cannot write outside its own folder"
# A deck.md is something colleagues send each other, so `cp` must not be
# reachable with a path that climbs out of the build sandbox.
rm -f "$WORK/escaped.png"
cp assets/sample-photo.jpg "$WORK/elsewhere-src.png" 2>/dev/null || true
mkdir -p "$WORK/trav"
cp assets/sample-photo.jpg "$WORK/trav/pic.png"
printf '@split image=../escaped.png\n# T\nBody\n' > "$WORK/trav/deck.md"
cp assets/sample-photo.jpg "$WORK/escaped-source.png"
out=$(./render-deck.sh "$WORK/trav/deck.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "must stay inside the deck"; then
  ok "an image path with '..' is refused"
else
  bad "path traversal" "rc=$rc out=$(echo "$out" | tail -1)"
fi

printf '@statement\n# Schemes\nsub: repo at ssh://git.example.com/x.git today\n' > "$WORK/scheme.md"
if ./render-deck.sh "$WORK/scheme.md" "$WORK/scheme.pdf" >/dev/null 2>&1; then
  ok "a non-http scheme (ssh://) does not open a Typst comment"
else
  bad "scheme://" "the build died - only http/https are exempt from escaping"
fi

mkdir -p "$WORK/link-src"
cp assets/sample-photo.jpg "$WORK/link-src/outside.jpg"
mkdir -p "$WORK/linkdeck"
ln -sfn "$WORK/link-src" "$WORK/linkdeck/out"
printf '@split image=out/outside.jpg\n# T\nBody\n' > "$WORK/linkdeck/deck.md"
out=$(./render-deck.sh "$WORK/linkdeck/deck.md" "$WORK/x.pdf" 2>&1); rc=$?
if [ $rc -ne 0 ] && echo "$out" | grep -q "resolves outside the deck"; then
  ok "an image reached through a symlink out of the folder is refused"
else
  bad "symlink escape" "rc=$rc out=$(echo "$out" | tail -1)"
fi

# ...and the same guard must not fire on a deck reached THROUGH a symlink, which
# is every path under /tmp on macOS.
mkdir -p "$WORK/real"
cp assets/sample-photo.jpg "$WORK/real/pic.jpg"
printf '@split image=pic.jpg\n# T\nBody\n' > "$WORK/real/deck.md"
ln -sfn "$WORK/real" "$WORK/vialink"
if ./render-deck.sh "$WORK/vialink/deck.md" "$WORK/vialink.pdf" >/dev/null 2>&1; then
  ok "a deck behind a symlinked parent still builds"
else
  bad "symlinked parent" "the guard fired on a legitimate path"
fi

head_ "install.sh against a throwaway HOME"
mkdir -p "$WORK/home/.claude" "$WORK/bin"
cat > "$WORK/bin/claude" <<'FAKE'
#!/usr/bin/env bash
case "$*" in
  "plugin marketplace list") printf '  serokell-docs\n' ;;
  "plugin list") echo "serokell-docs@serokell-docs" ;;
esac
exit 0
FAKE
chmod +x "$WORK/bin/claude"
printf '{"model":"opus"}\n' > "$WORK/home/.claude/settings.json"
if HOME="$WORK/home" PATH="$WORK/bin:$PATH" SKIP_TYPST=1 bash install.sh >"$WORK/inst.log" 2>&1 \
   && python3 -c "
import json, sys
d = json.load(open('$WORK/home/.claude/settings.json'))
sys.exit(0 if d['extraKnownMarketplaces']['serokell-docs']['autoUpdate'] is True
              and d.get('model') == 'opus' else 1)"; then
  ok "it enables autoUpdate and keeps the existing settings"
else
  bad "install.sh" "$(tail -2 "$WORK/inst.log")"
fi

printf '[]\n' > "$WORK/home/.claude/settings.json"
rm -f "$WORK/home/.claude/settings.json.bak"
if HOME="$WORK/home" PATH="$WORK/bin:$PATH" SKIP_TYPST=1 bash install.sh >"$WORK/inst2.log" 2>&1 \
   && grep -q "not a JSON object" "$WORK/inst2.log" \
   && [ ! -e "$WORK/home/.claude/settings.json.bak" ]; then
  ok "settings that are not an object are left alone, without a stray backup"
else
  bad "install.sh non-object settings" "$(tail -2 "$WORK/inst2.log")"
fi

# ------------------------------------------- read-only install compatibility
head_ "Nothing is written inside the template"
mkdir -p "$WORK/elsewhere"
cp assets/sample-photo.jpg "$WORK/elsewhere/pic.jpg"
printf '@split image=pic.jpg\n# From another directory\nThe image sits next to the deck.\n' > "$WORK/elsewhere/deck.md"
if ./render-deck.sh "$WORK/elsewhere/deck.md" >/dev/null 2>&1 && [ -s "$WORK/elsewhere/deck.pdf" ]; then
  ok "a deck outside the repo builds, PDF lands next to it"
else
  bad "external deck" "did not produce $WORK/elsewhere/deck.pdf"
fi

# Compare against the snapshot taken BEFORE the first build in this run, and
# include ignored files: a plugin install is read-only, so a build that writes
# anything here at all - gitignored or not - breaks that install.
# __pycache__ is excluded on purpose: CPython writes it when test.sh imports
# slidegen, and silently skips it when the directory is read-only, so it cannot
# break a plugin install. Anything else appearing here can.
after_tree=$(find . -name .git -prune -o -name __pycache__ -prune -o \
                    -type f -newer "$STAMP" -print 2>/dev/null | sort)
if [ -z "$after_tree" ]; then
  ok "no file inside the template was written during the whole run"
else
  bad "a build wrote inside the template" "$(echo "$after_tree" | head -3 | tr '\n' ' ')"
fi

# --------------------------------------------------------------------- done
printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
