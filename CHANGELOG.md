# Changelog

## 0.6.0

**A deck now reads as one object.** The cover opened on the brand range and
every slide after it was a plain white page. The range is washed in behind all
of them at a few per cent - texture on the page rather than a picture - with the
cover left alone, since it carries the same photograph at full strength. Light
and dark carry different values (the snow is light, so what whispers on white
shouts on a dark page); `BGART` overrides them, `BGART=0` gives plain pages back
for a deck of dense tables or edge-to-edge screenshots.

**The accent finally reaches author text.** `deck.md` is deliberately literal,
so the one thing a speaker wants to mark - the operative word of a headline -
could not be marked at all. `*asterisks*` set a span in the brand red, in any
field of any layout. The builder warns at two spans on a slide: red that lands
twice reads as decoration rather than emphasis.

**Cyrillic in documents was silently wrong.** The slide template listed the
bundled Golos Text after Google Sans Flex, the document template did not, so a
Russian document fell through to Typst's default serif - no error, no warning,
just a face that belongs to no template. Fixed, and both paths are now asserted
on the embedded fonts rather than by eye.

**Type and spacing, after a full read of the catalog.** The scale moves one step
up (45.8/29.3/23.4pt), so a headline carries a room. The subhead goes back to
being one line that finishes a heading: seven layouts were setting whole
paragraphs in it, which reads as a heavy block, not as a level of hierarchy -
those are body text now. Gaps that had drifted into hardcoded millimetres take
their shared tokens again, the annotated-visual device no longer overlaps the
heading band, and the quote attribution is a muted line rather than a subhead.
The `kpis` layout is gone - it was `metric-cols` with a different label - and
`@kpis` maps onto it, so existing decks keep building.

**Cards hold their edge over the art.** A light card tuned against a white page
disappeared where a mountain shoulder crossed it; the fill and hairline are a
couple of steps darker. The code panel is now the same surface as a card - it
had its own near-miss grey - so the deck has one kind of raised block instead of
two.

Page numbers read "7 / 41", with the total muted.

## 0.5.0

**Slide decks, composed rather than marked up.** The repository already had a
16:9 slide layout library; what it lacked was a way for anyone but its author to
use it. `serokell-slides` is now a skill next to `serokell-pdf` and
`serokell-cv`: you describe the deck and hand over your notes, the model splits
them into slides, picks a layout for each one, and renders the PDF next to your
file. You edit in words afterwards - "slide 3 as two columns", "drop slide 6" -
and never open Typst.

The authoring format (`deck.md`) now reaches the whole library. Its generator
knew 13 layouts out of 45, so everything added recently - timelines, KPI rows,
tables, matrices, funnels, team and testimonial slides, device mockups - was
unreachable from markdown, and two tags called the library by signatures it no
longer had. All 37 slide layouts are addressable, `decks/all-layouts.md` shows
each one, and `FORMAT.md` documents the fields.

`render-deck.sh` builds a deck living anywhere on disk, copying it and its
images into a temp directory, so nothing is written inside the template - which
is what a plugin installed read-only requires.

**A slide with too much text is clipped, not reflowed.** The frame has a fixed
height, so overflow is cut off at the edges rather than pushed to a second page,
and no page count can detect it. The generator therefore carries a per-layout
length budget and warns before the PDF exists. It also fixes a deck with no
frontmatter failing to build at all, silently: with `pipefail`, a non-matching
`grep` in the theme lookup aborted the script without printing anything.

**Hardening before the repository went public.** A review of the whole diff
found several things worth naming:

- An image path could climb out of the build sandbox. `image=../x.png` made the
  build copy through `..`, so a `deck.md` received from someone else could write
  anywhere the person running it can write. Both entry points now refuse a path
  that leaves the document's folder.
- A missing image was documented as falling back to a grey placeholder and in
  fact killed the build with a Typst error naming a temp directory that had
  already been deleted. It now stops with the filename as the author wrote it,
  and the placeholder is what you get by leaving the image off the slide.
- `//` in author text opened a Typst comment and swallowed the rest of the line,
  reported as "unclosed delimiter" in a generated file the author never sees.
- Malformed numeric options (`perrow=two`) raised a Python traceback instead of
  saying which option was wrong; a deck with no layout tag at all reported an
  unknown layout named after its first word.
- The installer could leave someone with no plugin at all if the download failed
  after the old copy was removed, overwrote its own settings backup on a second
  run, and reported failure after a successful install when the settings file
  was not valid JSON. Its `claude` calls now read from `/dev/null`, so a prompt
  cannot eat the rest of the script under `curl | bash`.
- Two tests could not fail: the tree check snapshotted the tree after the builds
  it was meant to police (and everything a build writes is gitignored), and the
  dark-theme check only asserted that Typst exited cleanly, so it passed with
  the theme wired to a constant. Both are now discriminating - file mtimes
  against a stamp taken before anything runs, and the mean luminance of a
  rendered page. The suite grew from 16 checks to 27.

A second review pass over those fixes found more, all included here: the
missing-image check missed `@image-row`, which passes its paths positionally,
and false-positived on a `@code` slide quoting an `img:` line - so the build now
asks the generator which images it emitted (`slidegen.py --images`) instead of
grepping the file it produced. Escaping `//` was too broad and stripped the link
annotation from every URL, which is a worse bug than the one it fixed. `render.sh`
- the path documents and profiles take - kept the old "skipping" warning followed
by a Typst failure. The installer's marketplace probe never matched real CLI
output, so `marketplace update` had quietly stopped running, and a settings file
holding valid JSON that is not an object still ended in a traceback. An image
that resolves through a symlink outside the source folder is refused as well:
no write escaped, but a build should not read from elsewhere either.

A third pass found what those fixes still left half-done, and the theme is that
each lived in one half of a pair. The image *check* moved to the generator while
the *copy* loop beside it still grepped the source, so a path merely mentioned
in a code sample aborted the build and a filename with a space, a capital or
Cyrillic was not found; both now take the generator's list. `render.sh` did not
see reference-style images (`![alt][id]`) at all. Exempting `://` from escaping
was too generous - Typst auto-links exactly `http` and `https`, so `ssh://` and
every other scheme still opened a comment. The symlink guard compared a logical
path against a physical one, which rejects any deck under `/tmp` on macOS. The
suite is 34 checks and now runs `install.sh` itself against a throwaway HOME.

Exploration files (nine background-artwork iterations, cover variants, a broken
sample) left the repository root; the two type specimens moved to
`dev/specimens/`. Assets now carry their provenance: `assets/CREDITS.md` records
every one, the bundled Golos Text ships its OFL licence, the sample photograph
was replaced with a public-domain one, and `NOTICE` states that the Serokell
marks and brand artwork are not covered by the repository's Apache-2.0 licence.

## 0.4.0

**The installer sets up Typst as well.** It used to print instructions and leave
you to it, which meant the one-command install was not actually one command. It
now uses Homebrew when that is already present, and otherwise downloads the
official static binary into `~/.local/bin`. It never installs Homebrew itself
and never asks for sudo, since putting a package manager on someone's machine is
a much larger change than this script should make. `SKIP_TYPST=1` opts out.

## 0.3.1

**One label per line, with no exceptions.** Role and stack used to share a line
under a project heading while the header block above put every label on its own
line, which was two rules in one document. Measured on a real profile the packed
line saved a couple of lines and did not change the page count, and the rule it
needed ("split it if it would wrap") asked the model to predict rendered line
length, which it cannot do reliably.

## 0.3.0

**One-command install.** `install.sh` registers the marketplace, installs the
plugin, and turns on automatic updates. The Claude CLI has no flag for that last
part, so the script writes the setting itself; it backs the settings file up
first, touches only that one key, and can be run again safely.

## 0.2.1

**Project metadata no longer repeats the client.** The project heading already
names the client, so a `Client:` line underneath said the same thing twice and
pushed the metadata line long enough to wrap, which loses its structure. The
line now carries role and stack only, and the skill says to fall back to one
label per line if it would still wrap.

## 0.2.0

**Emoji now work, in colour.** Noto Color Emoji is bundled as a fallback on
every face, so an emoji typed anywhere in the Markdown renders instead of
appearing as an empty box. The COLRv1 build is used because it is vector and
stays sharp in print. Apple Color Emoji cannot be bundled; its licence does not
allow redistribution.

**A skill for candidate profiles.** Hand over rough notes about a person and get
a profile back in the house structure, without writing any Markdown yourself.
The skill fixes the section order and the formatting devices that carry it, and
it asks for missing facts rather than inventing them.

**Build-time advice on common Markdown mistakes.** Every build now prints
`hint:` lines for the two mistakes that are invisible until someone reads the
finished PDF: adjacent `Label: value` lines, which Markdown merges into one
paragraph, and repeated generic headings. These are suggestions and never block
the build.

**Looser spacing around headings.** The gap below every heading grew so a
heading no longer sits tighter to its text than two paragraphs sit to each
other, and the gap above H1 grew so a major section break reads as larger than a
subsection break.

Existing documents are unaffected by the font change: the example renders
pixel-identical to the previous version.

## 0.1.0

First release. Markdown in `content/` becomes a branded PDF through one command,
with the cover page driven by frontmatter, bundled fonts and artwork so output
does not depend on the machine, and a table width setting as the single
adjustable layout choice.
