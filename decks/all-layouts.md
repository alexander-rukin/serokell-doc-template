---
theme: light
---

@cover
# Every deck layout
subtitle: A test deck - one slide per tag
meta: Serokell · 2026

@agenda
# Contents
- Opening slides
- Text and lists
- Numbers
- Diagrams
- People and visuals

@section
# Opening

@statement
# One large idea, the whole slide
sub: And a line of explanation beneath it, if it needs one

@callout
# An important callout with a red rule down the left
sub: A supporting line

@quote
# We chose Haskell not out of love for theory, but because the cost of a mistake in production is higher
who: CTO

@highlight
# Label
A paragraph of explanation on the right. Plenty of air, one idea, no lists.

@section
# Text and lists

@bullets
# A list heading
lead: An explanation under the heading
- First point | A short note about it
- Second point | And one about this too
- Third point | One more line

@two-col
# Two columns
- Left | The first line of thought, a couple of lines to check how it wraps.
- Right | A second line of thought, running parallel to the first.

@columns
# Open columns
lead: No cards, straight onto the page
- Audit | We read the code and find the vulnerabilities
- Development | We build in Haskell, Rust and Nix
- Support | We keep the system running after launch

@cards
# Cards
lead: Three cards, each a heading and a body
- Speed | A first prototype in two weeks
- Reliability | Formal methods where a mistake is expensive
- Transparency | A report after every iteration

@feature-grid
# A two by two grid
lead: Four points in the right half
- Types | Errors are caught at compile time
- Tests | Property-based on the critical paths
- Review | A second engineer reads every merge
- Monitoring | Metrics from day one

@steps
# How we work
- We take the problem apart and agree on the criteria
- We build a prototype and test the hypothesis
- We take it to production and hand it to the team

@compare
# Before and after
- BEFORE | Reconciling three spreadsheets by hand, two days per report
- AFTER | One pipeline, a report in four minutes

@table
# Comparing approaches
head: Approach | Speed | Risk
- Manual | Low | High
- Scripted | Medium | Medium
- Typed | High | Low

@code
# A code example
caption: Building a deck with one command
```sh
./build-deck.sh decks/my-deck.md
```

@highlight
# Cyrillic
Кириллица набирается тем же шрифтом. Golos Text лежит в репозитории, поэтому текст выглядит одинаково на любой машине.

@section
# Numbers

@stat
# 98%
caption: of critical paths covered by tests
sub: measured over the last quarter

@metric-cols
# What it bought us
- 40% | Less time spent preparing a report for every release
- 3x | Faster to bring a new engineer onto a project
- 0 | Production incidents in six months

@metric-grid
# Metrics
desc: The four numbers we watch every week
- 40% | Build time
- 12 | Releases
- 98% | Uptime
- 3 | Teams

@metric-list
# Results
lead: Three numbers, each with a note
- 40% | Build | A full build of the project takes almost half the time
- 12 | Releases | We ship every week with no manual steps
- 98% | Uptime | Excluding scheduled maintenance

@section
# Diagrams

@timeline
# How a project runs
- Discovery | Two weeks on context and criteria
- Prototype | We test the main hypothesis
- Production | We ship it and hand it over

@roadmap
# How we got here
- 2019 | First projects in Haskell
- 2022 | Built up a formal verification practice
- 2024 | Smart contract audits as a line of work
- 2026 | Our own design system and templates

@matrix
# Where we play
desc: Positioned by price and by how hard the work is
x: Cheap | Expensive
y: Simple | Hard
- Mass market
- A niche where mistakes are expensive
- Automation
- Our segment

@venn
# The overlap
desc: We work where engineering meets the domain
- Engineering
- Us
- Domain

@nested
# Layers of the system
desc: From the core outwards
- Core
- Services
- Interfaces

@funnel
# The funnel
desc: How an enquiry becomes a project
- First contact
- Discovery
- Estimate
- Contract

@section
# People and visuals

@testimonial
# In one quarter the team closed what we had failed to move for a year
name: Product Lead
loc: Berlin

@testimonials
- They understood our legacy faster than we expected | Maria · CTO
- The only ones who told us honestly what not to build | Peter · Founder
- A report that both the engineers and the board could read | Anna · COO

@team
# Who works on the project
- Maria | Team lead
- Peter | Engineer
- Anna | Analyst
- Ivan | Designer

@split image=assets/sample-photo.jpg
# Text and a visual
Text on the left, an image on the right. With no image, a grey placeholder of the same size takes its place.

@image-row
# Three visuals
- assets/sample-photo.jpg | First | A short caption under the image
-  | Second | An empty path gives a grey placeholder
- assets/sample-photo.jpg | Third | And one more caption

@image-full
# One image, full width
image: assets/sample-photo.jpg
caption: A caption under the image

@mobile-showcase n=2
# A mobile interface
Text on the left, phone mockups on the right. The number of phones is set with the n option.

@desktop-showcase
# A desktop interface
Text on the left, a laptop mockup on the right.

@annotated
# Walking through a screen
- left | 50 | The first element
- right | 70 | The second element

@closing
# Thank you
sub: Serokell · 2026
