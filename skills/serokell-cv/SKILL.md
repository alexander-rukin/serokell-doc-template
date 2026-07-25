---
name: serokell-cv
description: Build a Serokell candidate profile or CV as a branded PDF from rough notes. Use when someone asks for a CV, resume, candidate profile, consultant profile, or engineer profile, or pastes raw notes about a person and wants them turned into a presentable document for a client. Handles the house structure, formatting, and the build.
---

# Serokell candidate profile

Turns rough notes about a person into a branded PDF that follows the house
structure for candidate profiles. The person supplying the notes should not have
to think about Markdown, layout, or which bits get emphasis.

## What you do

1. Read whatever they gave you, however messy.
2. Map it onto the structure below. Reorganise freely; do not reword claims.
3. Ask about anything missing that the structure needs (see "Ask, never invent").
4. Write the `.md`, build it, hand over the PDF, and say what you assumed.

## The structure

Follow this shape. Skip a section entirely if there is nothing for it rather
than inventing filler.

```markdown
---
title: Ada Whitfield
subtitle: Senior Backend Engineer
author: Serokell OÜ
date: July 2026
tables: full
---

# Profile

**Location:** Lisbon, Portugal

**Work:** Serokell since March 2021

**Languages:** Haskell, Rust, PostgreSQL

**Education:** MSc in Computer Science, University of Edinburgh (2017)

> **Areas of expertise**
>
> Distributed systems, formal verification, database internals

# Key project track

## Northwind Bank

**Role:** Backend Lead

**Stack:** Haskell, PostgreSQL

**Overview:** One or two sentences on what the engagement was and what the
person owned.

**Key contributions:**

- One achievement per bullet, starting with a verb.
- Keep each to a single line where possible.

# Domain expertise

> Finance and banking, telecom, cybersecurity
```

## Formatting rules

These are what make the page look considered rather than like a text dump.

- **A blank line between every `Label:` line.** Markdown joins adjacent lines
  into one paragraph, so without blank lines the whole header collapses into a
  run-on block. This is the single most common way these documents go wrong.
- **Bold the labels**, as `**Location:**`. That gives each line a visual anchor
  and lets the eye scan the column.
- **Name each project heading after the client**, not `## Project`. Repeated
  generic headings make the document unscannable.
- **Put flat lists of specialisms in a `>` callout**, not a bulleted list. It
  renders as a block with an accent rule and breaks up the page.
- **Use a table only for genuinely tabular data**, such as client, focus and
  status across several rows. A table of one column is worse than a list.
- **The project heading is the client name**, so do not repeat it as a
  `**Client:**` line underneath. Saying it twice is noise, and it is what pushes
  the metadata line long enough to wrap.
- **Every `**Label:**` gets its own line, everywhere in the document.** That
  includes role and stack under a project heading, not just the header block.
  One rule with no exceptions: packing two labels onto a line saves a couple of
  lines, does not change the page count in practice, and costs the consistency
  of having every label start a line.
- Emoji are supported and render in colour if they want them, but bold labels
  usually read better in a client-facing document.

## Ask, never invent

**Never invent a name, title, date, employer, client, or metric.** A plausible
wrong detail in a candidate profile sent to a client is worse than a visible
gap, and nobody will catch it.

If the notes do not say, ask. The things most often missing:

- the person's **name** and the **role title** for the subtitle
- whether a client can be **named** or has to be anonymised as, for example,
  "a European telecom operator"
- the **date** to put on it

If they would rather not supply something, leave it out and build without it.
A profile with no date is fine; an invented date is not.

Do not promote the first line of their notes into a title just because it is
first. Do not turn an approximate statement into a precise one: if the notes say
"led a small team", do not write "led a team of six".

## Anonymising a client

Client names are often under NDA. If asked to anonymise, describe the client by
sector and scale in the heading instead of naming them:
`## A European telecom operator`. Since the heading carries the client, there is
no second place to remember to change. Keep the work description intact; it is
the client identity that is sensitive, not the engineering.

## Building

```bash
"${CLAUDE_PLUGIN_ROOT}/render.sh" path/to/profile.md
```

Writes the PDF next to the source. See the `serokell-pdf` skill for the general
Markdown and template rules, which all apply here too.

## Cover page or not

By default these are short documents, so leading with the name as the document
title on page 1 reads better than spending a whole page on a cover. Keep the
frontmatter `title` and add `cover: false` for that. Use a cover when the
profile is long, part of a bigger pack, or the client expects a formal deck.

## Checking the result

Look at the rendered PDF before handing it over, not just the build output:

```bash
pdftoppm -png -r 110 profile.pdf /tmp/page   # then read /tmp/page-N.png
```

Check that the header block is a stack of separate lines rather than one
paragraph. That is the failure this document type runs into most.
