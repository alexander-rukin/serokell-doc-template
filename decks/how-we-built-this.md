---
theme: light
---

@cover
# How we built this repository
subtitle: The problem, the decisions behind the fix, and how to use the result
meta: Serokell · July 2026

@agenda
# What this covers
- The problem
- How we got to the solution
- What it is now
- How to use it
- What we learned

@section
# The problem

@statement
# Every document started from scratch
sub: Fonts, margins, artwork and spacing were rebuilt by hand each time - and each time slightly differently

@bullets
# What that cost us
lead: None of it was hard work, all of it was repeated work
- Inconsistency | Two documents from the same week did not look like one company
- Wasted hours | Reformatting is not design, but it takes the same afternoon
- A blocked queue | Only the file owners could produce anything branded
- Silent drift | Every copy of a template diverges the moment someone edits it

@highlight
# The real problem
Not that documents looked wrong. That the brand lived in people's habits and in copies of files, instead of living in one place that applies itself.

@section
# How we got to the solution

@steps
# The path, in four moves
- Lock the design once, in a template nobody edits per document
- Let authors write plain markdown and nothing else
- Discover that slides do not work that way at all
- Hand the layout decision to the model, not the author

@compare
# First decision: who owns the design
- CONSIDERED | Options per document - table width, spacing, a colour here and there. Flexible, and drifts within a week
- CHOSEN | One locked shell. Content is yours, the design is not. A brand change is one file, not thirty documents

@callout
# Slides broke the assumption
sub: In a document the layout is constant, so plain markdown carries everything. In a deck the layout IS the message - the same sentence set large, beside an image, or sliced into cards says three different things

@compare
# Second decision: who picks the layout
- CONSIDERED | The author tags every slide by hand. Precise, and asks a writer to hold 37 layouts in their head
- CHOSEN | The author brings text and intent, the model composes. Choosing a layout is design work

@columns
# Third decision: how it reaches people
lead: Three ways in, one was clearly enough for now
- A web service | Rejected for now: real work, for a company where everyone already has the tooling
- A cloned repo | Works, but everyone maintains their own copy and its drift
- A plugin | Chosen: one install, automatic updates, nothing to sync by hand

@statement
# The result of those three
sub: A locked template, an author format that never mentions layout, and a model that composes decks on request

@section
# What it is now

@bullets
# Four pieces, each replaceable
lead: The seams are what keep the brand in one place
- The template | Fonts, colour, spacing, artwork - the locked shell
- The library | 37 slide layouts, one function each
- The generator | Turns author markdown into layout calls, refuses what will not fit
- The skills | Documents, candidate profiles and decks, composed on request

@metric-cols
# Where it stands
- 37 | slide layouts
- 3 | skills in one plugin
- 34 | tests on every change

@section
# How to use it

@code
# Install it once
caption: Registers the plugin, turns on automatic updates, and installs Typst if it is missing
```sh
curl -fsSL https://raw.githubusercontent.com/alexander-rukin/serokell-doc-template/main/install.sh | bash
```

@bullets
# Then ask, in your own words
lead: In Claude Code, from whatever folder your notes are in
- A document | "Make a PDF from proposal.md"
- A profile | "Turn these notes into a candidate profile"
- A deck | "A 15-minute client deck on our audit process - notes below"

@steps
# What happens when you ask for a deck
- It splits your material into slides and picks a layout for each
- It writes a deck.md next to your notes
- It renders the PDF and checks every page
- It hands you the file and says what it did

@code
# What a slide looks like in the source
caption: Readable and editable by hand - a tag saying what the slide does, then what it says
```md
@compare
# First decision: who owns the design
- CONSIDERED | Options per document. Flexible, and drifts
- CHOSEN | One locked shell. A brand change is one file
```

@bullets
# Correcting it is a conversation
lead: You never open Typst, and rarely the markdown
- Structure | "Slide 3 as two columns", "drop 6", "split that one"
- Emphasis | "Make the number the whole slide", "this is the punchline"
- Length | "Shorter", "one idea per slide here"
- Look | "Dark theme" - both palettes come from the same file

@columns
# Two things worth knowing
lead: They come up on almost every deck
- Images | Point at a file next to your deck; leave the image off a slide and you get a grey panel the right size instead
- Warnings | "This layout holds about 420 characters" means text would be cut off - shorten it or split the slide

@table
# Where things live
head: File | What it is
- deck.md | Your deck: one tag plus text per slide
- docs/FORMAT.md | Every layout and its fields
- decks/all-layouts.md | One slide per layout, rendered
- src/slides.typ | The layout library and the locked brand

@section
# What we learned

@cards
# Three traps, already paid for
- Silent clipping | Text past the frame is cut off, not reflowed - so length is checked before the PDF exists
- A stale facade | The library grew to 45 layouts while the author format still reached 13
- Read-only install | A plugin cannot write inside itself, so every build works in a temp directory

@statement
# Dogfooding found what tests did not
sub: This deck is the first real use of the flow, and building it surfaced two bugs nobody had thought to test for

@cards
# Then an outside review found more
- A hole | An image path with ../ escaped the build sandbox: a deck someone sends you could overwrite your files
- A lie | "A missing image falls back to a placeholder" was in the docs, not in the code - the build just died
- Decorative tests | Two checks could not fail whatever we broke, which is worse than not having them

@roadmap
# How it grew
- 20 July | Markdown to a branded PDF, design locked from day one
- 23 July | Slides: a layout library, then a format to author decks in
- 24 July | Profiles, one-command install, automatic updates
- 25 July | Every layout reachable, a test suite, decks as a skill

@bullets
# Open threads
lead: Nothing here blocks daily use
- More layouts | Added when a real deck needs one, not speculatively
- Shared assets | Diagrams and screenshots worth reusing across decks
- A service | Only if people outside the terminal end up needing decks

@closing
# The brand is a dependency, not a chore
sub: Serokell · July 2026
