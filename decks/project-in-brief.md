---
theme: light
---

@cover
# The document template, *in brief*
subtitle: What the problem was, how we solved it, and how to use the result
meta: Serokell · July 2026

@statement
# Every branded document started *from scratch*
sub: Fonts, margins, artwork and spacing rebuilt by hand each time, and each time slightly differently

@cards
# What that cost
lead: None of it was hard work. All of it was repeated work.
- Inconsistency | Two documents from the same week did not look like one company
- Wasted afternoons | Reformatting is not design, but it takes the same time
- A blocked queue | Only the people who owned the files could produce anything branded

@highlight
# The real problem
The brand lived in habits and in copies of files, instead of in *one place that applies itself*.

@compare
# The decision everything else follows from
- CONSIDERED | Options per document - table width, spacing, a colour here and there. Flexible, and drifts within a week
- CHOSEN | One locked shell. The content is yours, the design is not. A brand change is one file, not thirty documents

@callout
# Slides broke that assumption once
sub: In a document the layout is constant, so plain Markdown carries everything. In a deck the layout IS the message - so the author brings text and intent, and the model picks the layout

@metric-cols
# Where it stands
- 37 | layouts you can address
- 3 | skills in one plugin
- 40 | tests on every change

@code
# Install it once
caption: Registers the plugin, turns on automatic updates, and installs Typst if it is missing
```sh
curl -fsSL https://raw.githubusercontent.com/alexander-rukin/serokell-doc-template/main/install.sh | bash
```

@bullets
# Then ask in your own words
lead: In Claude Code, from whatever folder your notes are in
- A document | "Make a PDF from proposal.md"
- A profile | "Turn these notes into a candidate profile"
- A deck | "A 15-minute client deck on our audit process - notes below"

@steps
# What happens when you ask for a deck
- Your material is split into slides, each one given a layout
- A deck.md is written next to your notes, readable and editable
- The PDF is rendered and every page checked
- You correct it in words: "slide 3 as two columns", "drop 6", "dark theme"

@closing
# The brand is a dependency, *not a chore*
sub: Serokell · July 2026
