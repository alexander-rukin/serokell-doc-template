#!/usr/bin/env python3
"""
slidegen.py - turn an author-friendly deck.md into a Typst deck that uses the
Serokell slide layout library (slides.typ), which compiles to a branded PDF.

The author edits ONE markdown file: per-slide layout tag + plain text. No Typst,
no layout code. Run build-deck.sh to regenerate the PDF in seconds.

Usage:  python3 slidegen.py deck.md  >  _deck.typ

Format (see FORMAT.md):
  ---                      # optional deck frontmatter (key: value)
  theme: dark
  ---

  @cover                   # a slide starts with @<layout> [key=value ...]
  # Big title              # '#'  -> the slide's headline / big text
  subtitle: One-liner      # 'key: value' -> a named field
  meta: Serokell . 2026

  @bullets
  # Heading
  lead: optional lead line
  - Label | supporting text   # '- ' -> item; ' | ' splits an item into parts
  - Another | line

  @split image=assets/x.png
  # Heading
  Body paragraph goes here as plain prose.

Every layout in slides.typ that is a real slide has a tag here; see LAYOUTS.
"""
import sys, re

# Field names recognised as `key: value`. Anything else stays body prose.
KNOWN_KEYS = {
    "title", "subtitle", "meta", "sub", "lead", "caption", "who", "name", "loc",
    "number", "image", "label", "left", "right", "a", "b", "body", "desc",
    "head", "x", "y", "no",
}


# ---------------------------------------------------------------- text helpers

def _int_opt(layout, name, raw):
    """A whole-number option off the @layout line, or an error naming it."""
    try:
        return int(raw)
    except ValueError:
        die("@%s: %s= must be a whole number, got %r" % (layout, name, raw))


def _num(layout, name, raw):
    """A number inside an item, or an error naming what was expected."""
    try:
        return float(raw)
    except ValueError:
        die("@%s: %s must be a number (0 at the top, 100 at the bottom), got %r"
            % (layout, name, raw))


def esc(s):
    """Escape Typst markup-significant chars so author text stays literal."""
    if s is None:
        return ""
    s = s.replace("\\", "\\\\")
    for ch in "#[]*_`$<>@~":
        s = s.replace(ch, "\\" + ch)
    # `//` starts a Typst line comment, which would swallow the rest of the
    # generated line including its closing bracket - the author would get
    # "unclosed delimiter" pointing at a temp file. Exactly two prefixes are
    # exempt, because Typst auto-links exactly two: http:// and https://, where
    # escaping would cost the PDF's link annotation. Every other scheme -
    # ssh://, ftp://, postgres:// - IS read as a comment and must be escaped.
    s = re.sub(r"(?<!https:)(?<!http:)//", r"\\/\\/", s)
    return s


# The one piece of inline markup a deck.md has: *a span in asterisks* is set in
# the brand red and bold (#ac in the layout library). Everything else the author
# types stays literal, which is why esc() escapes the asterisk - a lone one, or a
# pair spanning a line break, is still just a character.
ACCENT_RE = re.compile(r"\*([^*\n]+)\*")


def strip_accent(s):
    """Author text with the accent markers removed - what the reader will see."""
    return ACCENT_RE.sub(r"\1", s or "")


def markup(s):
    """Escape author text, turning *spans* into accented ones."""
    out, pos = [], 0
    for m in ACCENT_RE.finditer(s):
        out.append(esc(s[pos:m.start()]))
        out.append("#ac[" + esc(m.group(1)) + "]")
        pos = m.end()
    out.append(esc(s[pos:]))
    return "".join(out)


def content(s):
    """Author text -> a Typst content literal [ ... ]; blank line -> paragraph."""
    parts = [p.strip() for p in re.split(r"\n\s*\n", (s or "").strip()) if p.strip()]
    body = "\n\n".join(markup(p).replace("\n", " \\\n") for p in parts)
    return "[" + body + "]"


IMAGES = []          # every image path emitted, in order; see --images


def path_lit(p):
    """A file path as a Typst string literal, recorded for the build to check."""
    p = (p or "").strip().strip('"')
    if '"' in p or "\\" in p:
        die('image path must not contain quotes or backslashes: %s' % p)
    IMAGES.append(p)
    # Anchored at the project root, so the same literal resolves whether the
    # generated file sits in src/ of a checkout or in a build sandbox.
    return '"/' + p.lstrip("/") + '"'


def arr(items):
    """Typst array literal; a 1-element array needs a trailing comma."""
    inner = ", ".join(items)
    if len(items) == 1:
        inner += ","
    return "(" + inner + ")"


def die(msg):
    raise SystemExit("deck.md: " + msg)


def warn_line(msg):
    """Something the author probably did not mean, that is not fatal."""
    print("warning: " + msg, file=sys.stderr)


# ---------------------------------------------------------------- deck parsing

def split_slides(text):
    fm = {}
    m = re.match(r"\s*---\s*\n(.*?)\n---\s*\n", text, re.S)
    if m:
        for ln in m.group(1).splitlines():
            if ":" in ln:
                k, v = ln.split(":", 1)
                fm[k.strip()] = v.strip()
        text = text[m.end():]
    # Split on lines starting with @layout - but NOT inside a code fence, where
    # `@compare` is sample text, not a new slide (a deck about this format shows
    # its own source; without this guard the example silently became a slide).
    # Each chunk carries whether it actually started with a tag: text sitting
    # before the first @layout is not slide 1, it is a mistake, and saying so
    # beats reporting "unknown layout @Just" from its first word.
    chunks, cur, tagged, in_fence = [], [], False, False
    for ln in text.splitlines():
        if ln.strip().startswith("```"):
            in_fence = not in_fence
        elif not in_fence and re.match(r"@[\w-]", ln):
            chunks.append((tagged, "\n".join(cur)))
            cur, tagged = [], True
            ln = ln[1:]           # drop the leading @, as the old split did
        cur.append(ln)
    chunks.append((tagged, "\n".join(cur)))

    slides = []
    for is_tagged, ch in chunks:
        ch = ch.strip("\n")
        if not ch.strip():
            continue
        if not is_tagged:
            first = ch.strip().splitlines()[0][:60]
            die("every slide must start with a layout tag such as '@statement'.\n"
                "  This text has none: %r\n"
                "  See FORMAT.md for the layouts." % first)
        head, _, rest = ch.partition("\n")
        toks = head.split()
        layout = toks[0]
        opts = {}
        for tok in toks[1:]:
            if "=" in tok:
                k, v = tok.split("=", 1)
                opts[k] = v.strip('"')
            else:
                # a bare word here is almost always an option with a space in it
                # (`image=my photo.png`), and silently dropping it loses the image
                warn_line("@%s: ignoring %r on the layout line - options are "
                          "key=value with no spaces; put wordier values on a "
                          "'key: value' line instead" % (layout, tok))
        slides.append((layout, opts, rest))
    return fm, slides


# Options accepted on the `@layout ...` line. They cannot hold spaces - anything
# wordier (a caption, a label) is a `key: value` line in the body instead.
KNOWN_OPTS = {"image", "bleed", "n", "perrow", "avatars", "no"}


def parse_block(rest):
    """Pull headline (#), fields (key:), items (-), a code fence and body prose."""
    f = {"title": None, "items": [], "quote": [], "body": [], "fields": {}, "code": None}
    lines = rest.splitlines()
    i = 0
    while i < len(lines):
        ln = lines[i]
        s = ln.strip()
        if s.startswith("```"):
            lang = s[3:].strip() or "text"
            buf = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                buf.append(lines[i]); i += 1
            f["code"] = (lang, "\n".join(buf))
            i += 1
            continue
        if s.startswith("# "):
            f["title"] = s[2:].strip()
        elif s.startswith("> "):
            f["quote"].append(s[2:].strip())
        elif s.startswith("- "):
            f["items"].append(s[2:].strip())
        else:
            m = re.match(r"([A-Za-z][\w-]*):\s+(.*)", s)
            if m and m.group(1) in KNOWN_KEYS:
                f["fields"][m.group(1)] = m.group(2).strip()
            elif s:
                f["body"].append(ln)
        i += 1
    f["body"] = "\n".join(f["body"]).strip()
    return f


def field(f, name, default=None):
    return f["fields"].get(name, default)


# ------------------------------------------------------- item shape validation

def parts(item, n, layout, shape):
    """Split '- a | b | c' into exactly n parts, or explain what was expected."""
    got = [p.strip() for p in item.split("|")]
    if len(got) < n:
        die("@%s: item %r needs %d parts separated by ' | ' (%s)" % (layout, item, n, shape))
    if len(got) > n:                       # extra pipes fold into the last part
        got = got[: n - 1] + [" | ".join(got[n - 1:])]
    return got


def need_items(f, layout, lo, hi=None):
    n = len(f["items"])
    if n < lo or (hi is not None and n > hi):
        want = "%d" % lo if hi == lo else ("%d-%d" % (lo, hi) if hi else "at least %d" % lo)
        die("@%s expects %s items ('- ...' lines), got %d" % (layout, want, n))
    return f["items"]


def need_field(f, layout, key):
    v = field(f, key)
    if v is None:
        die("@%s needs a '%s:' line" % (layout, key))
    return v


def pair_list(f, layout, n, shape, lo=1, hi=None):
    return arr([
        "(" + ", ".join(content(p) for p in parts(it, n, layout, shape)) + ")"
        for it in need_items(f, layout, lo, hi)
    ])


# -------------------------------------------------------------- slide emitters
# Each takes (layout, opts, f) and returns one Typst call.

def _cover(layout, opts, f):
    args = [content(field(f, "title", f["title"] or ""))]
    sub = field(f, "subtitle", " ".join(f["quote"]).strip())
    if sub:
        args.append("subtitle: " + content(sub))
    if field(f, "meta"):
        args.append("meta: " + content(field(f, "meta")))
    return "#cover(" + ", ".join(args) + ")"


def _section(layout, opts, f):
    if opts.get("no") or field(f, "no"):
        print("note: @section no=.. is ignored - section slides carry no number",
              file=sys.stderr)
    return "#section(" + content(f["title"] or f["body"]) + ")"


def _statement(layout, opts, f):
    args = [content(f["title"] or f["body"])]
    sub = field(f, "sub", " ".join(f["quote"]).strip())
    if sub:
        args.append("sub: " + content(sub))
    return "#statement(" + ", ".join(args) + ")"


def _closing(layout, opts, f):
    args = [content(f["title"] or f["body"])]
    if field(f, "sub"):
        args.append("sub: " + content(field(f, "sub")))
    return "#closing(" + ", ".join(args) + ")"


def _callout(layout, opts, f):
    args = [content(f["title"] or f["body"])]
    if field(f, "sub"):
        args.append("sub: " + content(field(f, "sub")))
    return "#callout(" + ", ".join(args) + ")"


def _bullets(layout, opts, f):
    out = []
    for it in need_items(f, layout, 1):
        if "|" in it:
            a, b = parts(it, 2, layout, "Label | text")
            out.append("(" + content(a) + ", " + content(b) + ")")
        else:
            out.append(content(it))
    args = [content(f["title"] or ""), arr(out)]
    lead = field(f, "lead")
    if lead:
        args.append("lead: " + content(lead))
    return "#bullets(" + ", ".join(args) + ")"


def _two_col(layout, opts, f):
    items = need_items(f, layout, 2, 2)
    a = parts(items[0], 2, layout, "Label | text")
    b = parts(items[1], 2, layout, "Label | text")
    return "#two-col(%s, (%s, %s), (%s, %s))" % (
        content(f["title"] or ""), content(a[0]), content(a[1]),
        content(b[0]), content(b[1]))


def _split(layout, opts, f):
    args = [content(f["title"] or ""), content(f["body"])]
    img = opts.get("image") or field(f, "image")
    if img:
        args.append("img: " + path_lit(img))
    elif field(f, "label"):
        args.append("label: " + content(field(f, "label")))
    if opts.get("bleed") in ("1", "yes", "true"):
        args.append("bleed: true")
    return "#split(" + ", ".join(args) + ")"


def _stat(layout, opts, f):
    number = field(f, "number", f["title"] or "")
    caption = field(f, "caption", f["body"] or " ".join(f["quote"]))
    args = [content(number), content(caption)]
    if field(f, "sub"):
        args.append("sub: " + content(field(f, "sub")))
    return "#stat(" + ", ".join(args) + ")"


def _quote(layout, opts, f):
    args = [content(f["title"] or " ".join(f["quote"]) or f["body"])]
    if field(f, "who"):
        args.append("who: " + content(field(f, "who")))
    return "#quote-slide(" + ", ".join(args) + ")"


def _compare(layout, opts, f):
    items = need_items(f, layout, 2, 2)
    a = parts(items[0], 2, layout, "HEAD | body")
    b = parts(items[1], 2, layout, "HEAD | body")
    return "#compare(%s, %s, %s, %s, %s)" % (
        content(f["title"] or ""), content(a[0]), content(a[1]),
        content(b[0]), content(b[1]))


def _code(layout, opts, f):
    lang, code = f["code"] or ("text", f["body"])
    fence = "```" + lang + "\n" + code + "\n```"
    args = [content(f["title"] or ""), "[" + fence + "]"]
    caption = field(f, "caption")
    if caption:
        args.append("caption: " + content(caption))
    return "#code-slide(" + ", ".join(args) + ")"


def _steps(layout, opts, f):
    items = arr([content(x) for x in need_items(f, layout, 2, 5)])
    return "#steps(%s, %s)" % (content(f["title"] or ""), items)


def _cards(layout, opts, f):
    args = [content(f["title"] or ""),
            pair_list(f, layout, 2, "NAME | body", 2, 4)]
    if field(f, "lead"):
        args.append("lead: " + content(field(f, "lead")))
    return "#cards(" + ", ".join(args) + ")"


def _agenda(layout, opts, f):
    items = arr([content(x) for x in need_items(f, layout, 2, 8)])
    return "#agenda(%s, %s)" % (content(f["title"] or ""), items)


def _kpis(layout, opts, f):
    # `@kpis` was a second figures-in-a-row layout whose only difference from
    # metric-cols was a one-line label instead of a paragraph. It is kept as an
    # alias so existing decks still render.
    return "#metric-cols(%s, %s)" % (content(f["title"] or ""),
                                     pair_list(f, layout, 2, "98% | label", 2, 4))


def _timeline(layout, opts, f):
    return "#timeline(%s, %s)" % (content(f["title"] or ""),
                                  pair_list(f, layout, 2, "Stage | description", 2, 5))


def _table(layout, opts, f):
    head = [h.strip() for h in need_field(f, layout, "head").split("|")]
    rows = []
    for it in need_items(f, layout, 1):
        cells = parts(it, len(head), layout, " | ".join(head))
        rows.append(arr([content(c) for c in cells]))
    return "#table-slide(%s, %s, %s)" % (
        content(f["title"] or ""), arr([content(h) for h in head]), arr(rows))


def _matrix(layout, opts, f):
    x = parts(need_field(f, layout, "x"), 2, layout, "left axis | right axis")
    y = parts(need_field(f, layout, "y"), 2, layout, "top axis | bottom axis")
    quads = need_items(f, layout, 4, 4)     # order: TL, TR, BL, BR
    return "#matrix2x2(%s, %s, %s, %s, %s)" % (
        content(f["title"] or ""), content(need_field(f, layout, "desc")),
        arr([content(x[0]), content(x[1])]), arr([content(y[0]), content(y[1])]),
        arr([content(q) for q in quads]))


def _highlight(layout, opts, f):
    label = f["title"] or field(f, "label")
    if not label:
        die("@highlight needs a '# label' line")
    return "#highlight(%s, %s)" % (content(label), content(f["body"]))


def _columns(layout, opts, f):
    args = [content(f["title"] or ""),
            pair_list(f, layout, 2, "Label | text", 2, 4)]
    if field(f, "lead"):
        args.append("lead: " + content(field(f, "lead")))
    return "#columns(" + ", ".join(args) + ")"


def _feature_grid(layout, opts, f):
    args = [content(f["title"] or ""),
            pair_list(f, layout, 2, "Label | text", 4, 4)]
    if field(f, "lead"):
        args.append("lead: " + content(field(f, "lead")))
    return "#feature-grid(" + ", ".join(args) + ")"


def _metric_list(layout, opts, f):
    args = [content(f["title"] or ""),
            pair_list(f, layout, 3, "40% | Label | description", 2, 4)]
    if field(f, "lead"):
        args.append("lead: " + content(field(f, "lead")))
    return "#metric-list(" + ", ".join(args) + ")"


def _metric_cols(layout, opts, f):
    return "#metric-cols(%s, %s)" % (content(f["title"] or ""),
                                     pair_list(f, layout, 2, "40% | paragraph", 2, 4))


def _metric_grid(layout, opts, f):
    return "#metric-grid(%s, %s, %s)" % (
        content(f["title"] or ""), content(need_field(f, layout, "desc")),
        pair_list(f, layout, 2, "40% | label", 4, 4))


def _roadmap(layout, opts, f):
    return "#roadmap(%s, %s)" % (content(f["title"] or ""),
                                 pair_list(f, layout, 2, "Date | what happened", 3, 6))


def _venn(layout, opts, f):
    items = need_items(f, layout, 3, 3)
    return "#venn(%s, %s, %s)" % (
        content(f["title"] or ""), content(need_field(f, layout, "desc")),
        arr([content(i) for i in items]))


def _nested(layout, opts, f):
    items = need_items(f, layout, 2, 4)
    return "#nested(%s, %s, %s)" % (
        content(f["title"] or ""), content(need_field(f, layout, "desc")),
        arr([content(i) for i in items]))


def _funnel(layout, opts, f):
    items = need_items(f, layout, 3, 5)
    return "#funnel(%s, %s, %s)" % (
        content(f["title"] or ""), content(need_field(f, layout, "desc")),
        arr([content(i) for i in items]))


def _testimonial(layout, opts, f):
    args = [content(f["title"] or " ".join(f["quote"]) or f["body"])]
    if field(f, "name") or field(f, "who"):
        args.append("name: " + content(field(f, "name", field(f, "who"))))
    if field(f, "loc"):
        args.append("loc: " + content(field(f, "loc")))
    return "#testimonial(" + ", ".join(args) + ")"


def _testimonials(layout, opts, f):
    args = [pair_list(f, layout, 2, "quote | Name · Place", 2, 4)]
    if opts.get("avatars") in ("0", "no", "false"):
        args.append("avatars: false")
    return "#testimonials(" + ", ".join(args) + ")"


def _team(layout, opts, f):
    args = [content(f["title"] or ""),
            pair_list(f, layout, 2, "Name | role", 2, 12)]
    if opts.get("perrow"):
        args.append("perrow: " + str(_int_opt(layout, "perrow", opts["perrow"])))
    return "#team(" + ", ".join(args) + ")"


def _image_row(layout, opts, f):
    cells = []
    for it in need_items(f, layout, 2, 3):
        img, lbl, desc = parts(it, 3, layout, "path.png | Label | description")
        cells.append("(%s, %s, %s)" % (
            path_lit(img) if img else "none", content(lbl), content(desc)))
    return "#image-row(%s, %s)" % (content(f["title"] or ""), arr(cells))


def _image_full(layout, opts, f):
    args = []
    img = opts.get("image") or field(f, "image")
    if img:
        args.append("img: " + path_lit(img))
    caption = field(f, "caption", f["title"])
    if caption:
        args.append("caption: " + content(caption))
    return "#image-full(" + ", ".join(args) + ")"


def _mobile(layout, opts, f):
    args = [content(f["title"] or ""), content(f["body"])]
    if opts.get("n"):
        args.append("n: " + str(_int_opt(layout, "n", opts["n"])))
    return "#mobile-showcase(" + ", ".join(args) + ")"


def _desktop(layout, opts, f):
    return "#desktop-showcase(%s, %s)" % (content(f["title"] or ""), content(f["body"]))


def _annotated(layout, opts, f):
    notes = []
    for it in need_items(f, layout, 1, 4):
        side, y, label = parts(it, 3, layout, "left|right | 40 | Label")
        if side not in ("left", "right"):
            die("@annotated: side must be 'left' or 'right', got %r" % side)
        notes.append('("%s", %s, %s)' % (side, _num(layout, "position", y), content(label)))
    args = []
    if f["title"]:
        args.append("title: " + content(f["title"]))
    img = opts.get("image") or field(f, "image")
    if img:
        args.append("img: " + path_lit(img))
    args.append("notes: " + arr(notes))
    return "#annotated(" + ", ".join(args) + ")"


LAYOUTS = {
    # opener / closer / single-idea
    "cover": _cover, "section": _section, "statement": _statement,
    "closing": _closing, "callout": _callout, "quote": _quote,
    "highlight": _highlight,
    # lists and text structures
    "bullets": _bullets, "two-col": _two_col, "columns": _columns,
    "cards": _cards, "feature-grid": _feature_grid, "agenda": _agenda,
    "steps": _steps, "compare": _compare, "table": _table, "code": _code,
    # numbers
    "stat": _stat, "kpis": _kpis, "metric-list": _metric_list,
    "metric-cols": _metric_cols, "metric-grid": _metric_grid,
    # diagrams / time
    "timeline": _timeline, "roadmap": _roadmap, "matrix": _matrix,
    "venn": _venn, "nested": _nested, "funnel": _funnel,
    # people
    "testimonial": _testimonial, "testimonials": _testimonials, "team": _team,
    # visuals
    "split": _split, "image-row": _image_row, "image-full": _image_full,
    "mobile-showcase": _mobile, "desktop-showcase": _desktop,
    "annotated": _annotated,
}


# --------------------------------------------------------------- length budget
# A slide that gets too much text does NOT spill onto a second page - the frame
# has a fixed height, so the text is silently CLIPPED at the top and bottom edge.
# Nothing downstream can detect that, so the only real guard is refusing to write
# more than the layout holds. These are the comfortable maxima, in characters;
# going over is a warning, not an error (a slightly long line is usually fine,
# double the budget is not).
#   title/body   - the '# ...' headline and the prose body
#   parts        - per-part budget for '- a | b | c' items
LIMITS = {
    "cover":            {"title": 60, "body": 0},
    "section":          {"title": 60},
    "statement":        {"title": 110},
    "closing":          {"title": 90},
    "callout":          {"title": 130},
    "quote":            {"title": 200},
    "highlight":        {"title": 40, "body": 340},
    "bullets":          {"title": 70, "parts": (40, 90), "bare": 95},
    "two-col":          {"title": 70, "parts": (30, 260)},
    "columns":          {"title": 70, "parts": (30, 130)},
    "cards":            {"title": 70, "parts": (24, 120)},
    "feature-grid":     {"title": 60, "parts": (30, 120)},
    "agenda":           {"title": 70, "parts": (60,)},
    "steps":            {"title": 70, "parts": (110,)},
    "compare":          {"title": 70, "parts": (24, 170)},
    "table":            {"title": 70, "parts": (40, 40, 40, 40, 40)},
    "stat":             {"title": 12},
    "kpis":             {"title": 70, "parts": (8, 130)},   # alias of metric-cols
    "metric-list":      {"title": 60, "parts": (8, 26, 90)},
    "metric-cols":      {"title": 70, "parts": (8, 130)},
    "metric-grid":      {"title": 60, "parts": (8, 30)},
    "timeline":         {"title": 70, "parts": (22, 90)},
    "roadmap":          {"title": 70, "parts": (14, 70)},
    "matrix":           {"title": 60, "parts": (40,)},
    "venn":             {"title": 60, "parts": (20,)},
    "nested":           {"title": 60, "parts": (20,)},
    "funnel":           {"title": 60, "parts": (30,)},
    "testimonial":      {"title": 220},
    "testimonials":     {"parts": (130, 34)},
    "team":             {"title": 70, "parts": (20, 26)},
    "split":            {"title": 70, "body": 420},
    "image-row":        {"title": 70, "parts": (999, 24, 90)},
    "image-full":       {"title": 90},
    "mobile-showcase":  {"title": 60, "body": 260},
    "desktop-showcase": {"title": 60, "body": 260},
    "annotated":        {"title": 70, "parts": (8, 8, 26)},
}


def check_accent(n, layout, f):
    """The brand accent is a spotlight: two of them on one slide is none."""
    fields = [f.get("title") or "", f.get("body") or ""]
    fields += list(f.get("items") or []) + list(f.get("quote") or [])
    fields += [v for k, v in (f.get("fields") or {}).items() if isinstance(v, str)]
    spans = sum(len(ACCENT_RE.findall(t)) for t in fields)
    if spans > 1:
        print("warning: slide %d (@%s): %d accented spans - the red carries one "
              "idea per slide, more and it stops reading as emphasis"
              % (n, layout, spans), file=sys.stderr)


def check_budget(n, layout, f):
    lim = LIMITS.get(layout, {})

    def warn(what, text, cap):
        # the asterisks are markup, not something the reader sees
        text = strip_accent(text)
        if cap and len(text) > cap:
            print("warning: slide %d (@%s): %s is %d chars, the layout holds about %d "
                  "- it will be clipped, shorten it or split the slide"
                  % (n, layout, what, len(text), cap), file=sys.stderr)

    if f["title"]:
        warn("the '# ' headline", f["title"], lim.get("title"))
    if f["body"]:
        warn("the body text", f["body"], lim.get("body"))
    caps = lim.get("parts")
    if caps:
        for it in f["items"]:
            got = [p.strip() for p in it.split("|")]
            # a bare one-line item (bullets accept those) is not a label - it gets
            # the whole row, so judge it by the layout's bare budget
            if len(got) == 1 and len(caps) > 1:
                warn("item %r" % (got[0][:24] + ("..." if len(got[0]) > 24 else "")),
                     got[0], lim.get("bare", max(caps)))
                continue
            for i, part in enumerate(got):
                cap = caps[i] if i < len(caps) else caps[-1]
                warn("item part %d (%r)" % (i + 1, part[:24] + ("..." if len(part) > 24 else "")),
                     part, cap)


def emit(layout, opts, f):
    fn = LAYOUTS.get(layout)
    if fn is None:
        die("unknown layout @%s. Known: %s" % (layout, ", ".join(sorted(LAYOUTS))))
    return fn(layout, opts, f)


def main():
    args = sys.argv[1:]
    # --images: run the whole generator, then print the image paths it emitted,
    # one per line, instead of the Typst. Grepping the generated file cannot do
    # this correctly - it cannot tell an argument from a fenced code sample, and
    # it misses layouts that pass paths positionally.
    list_images = "--images" in args
    args = [a for a in args if a != "--images"]
    if not args:
        sys.exit("usage: slidegen.py [--images] deck.md > _deck.typ")
    text = open(args[0], encoding="utf-8").read()
    fm, slides = split_slides(text)
    if not slides:
        die("no slides found - every slide starts with a line like '@cover'")
    out = ['#import "slides.typ": *', ""]
    for n, (layout, opts, rest) in enumerate(slides, 1):
        f = parse_block(rest)
        for k in opts:
            if k not in KNOWN_OPTS:
                print("warning: slide %d (@%s): unknown option %r on the @ line - it is "
                      "ignored. Options cannot contain spaces; use a '%s: ...' line in "
                      "the slide body instead." % (n, layout, k, k), file=sys.stderr)
        try:
            check_budget(n, layout, f)
            check_accent(n, layout, f)
            out.append(emit(layout, opts, f))
        except SystemExit as e:
            raise SystemExit("slide %d (@%s): %s" % (n, layout, str(e).replace("deck.md: ", "")))
        out.append("")
    if list_images:
        seen = []
        for img in IMAGES:
            if img and img not in seen:
                seen.append(img)
        sys.stdout.write("".join(i + "\n" for i in seen))
        return
    sys.stdout.write("\n".join(out))


if __name__ == "__main__":
    main()
