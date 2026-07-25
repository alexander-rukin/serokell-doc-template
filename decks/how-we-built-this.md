---
theme: light
---

@cover
# How we built this repository
subtitle: A house style that applies itself - documents, profiles and decks from plain markdown
meta: Serokell . July 2026

@agenda
# What this covers
- The problem worth solving
- What we built
- How a deck gets made
- What we learned building it
- Where it goes next

@section
# The problem

@statement
# Every document started from scratch
sub: Fonts, margins and the logo were rebuilt by hand each time, and each time slightly differently

@compare
# The shape of the fix
- BEFORE | Everyone reproduces the brand by hand, so no two documents match and nobody enjoys the work
- AFTER | Everyone writes plain markdown, the brand is applied by the template, and the output is identical everywhere

@highlight
# One decision
The design is not a set of suggestions to tune per document. It is decided once, locked in the template, and reused. Everything else about a document stays open.

@section
# What we built

@columns
# Three ways in, one house style
lead: Same fonts, same artwork, same rules underneath
- Documents | Proposals, reports and technical notes from a markdown file
- Profiles | Candidate profiles in a fixed structure the client already expects
- Decks | 16:9 presentations where a layout is chosen per slide

@bullets
# How it is put together
lead: Four pieces, each replaceable
- The template | The locked brand shell: fonts, colour, spacing, artwork
- The library | 37 slide layouts, one function each
- The generator | Turns author markdown into the layout calls
- The skills | Let the model do the composing on request

@code
# Installing it takes one command
caption: Registers the plugin, enables automatic updates, and installs Typst if it is missing
```sh
curl -fsSL https://raw.githubusercontent.com/alexander-rukin/serokell-doc-template/main/install.sh | bash
```

@section
# How a deck gets made

@steps
# From notes to PDF
- Describe the deck and hand over your notes
- The model splits them into slides and picks a layout for each
- It renders the PDF and checks every page
- You correct it in words and it rebuilds

@code
# You never write layout code
caption: This is the source of slide 5 in this deck - a tag saying what the slide does, then what it says
```md
@compare
# The shape of the fix
- BEFORE | Everyone reproduces the brand by hand
- AFTER | The template applies it, output identical
```

@kpis
# The system today
- 37 | slide layouts
- 3 | skills in one plugin
- 14 | tests on every change

@callout
# The layout carries the meaning
sub: The same sentence set large, pinned beside an image, or sliced into cards is three different statements - so choosing the layout is the composing work, not a formatting afterthought

@section
# What we learned

@cards
# Three traps, already paid for
- Silent clipping | Text past the frame is cut off, not reflowed - so length has to be checked before the PDF exists
- A stale facade | The library grew to 45 layouts while the author format still knew 13
- Read-only install | A plugin cannot write inside itself, so every build works in a temp directory


@roadmap
# How it grew
- 20 July | Markdown to a branded PDF, design locked from day one
- 23 July | Slides: a layout library and an authoring format
- 24 July | Candidate profiles, one-command install, automatic updates
- 25 July | Every layout reachable, a test suite, decks composed on request

@statement
# The test suite tests what fails quietly
sub: Not that the build succeeds - that a layout is unreachable, that text is clipped, that a build wrote inside the repository

@section
# Where it goes next

@bullets
# Open threads
lead: Nothing here blocks daily use
- More layouts | Added when a real deck needs one, not speculatively
- Shared assets | Diagrams and screenshots worth reusing across decks
- A service | Only if people outside the terminal end up needing decks

@closing
# The brand is a dependency, not a chore
sub: Serokell . July 2026
