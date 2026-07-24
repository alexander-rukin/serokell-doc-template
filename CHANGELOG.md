# Changelog

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
