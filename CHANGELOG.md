# Changelog

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
