# Changelog

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
