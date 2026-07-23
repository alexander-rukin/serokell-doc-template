#!/usr/bin/env python3
"""
slidegen.py - turn an author-friendly deck.md into a Typst deck that uses the
Serokell slide layout library (slides.typ), then that compiles to a branded PDF.

The author edits ONE markdown file: per-slide layout tag + plain text. No Typst,
no layout code. Run build-deck.sh to regenerate the PDF in seconds.

Usage:  python3 slidegen.py deck.md  >  _deck.typ

Format (see FORMAT.md):
  ---                      # optional deck frontmatter (key: value)
  theme: serokell
  ---

  @cover                   # a slide starts with @<layout> [key=value ...]
  # Big title              # '#'  -> the slide's headline / big text
  subtitle: One-liner      # 'key: value' -> a named field
  meta: Serokell . 2026

  @bullets
  # Heading
  lead: optional lead line
  - first point            # '- ' -> list item
  - second point

  @split image=assets/x.png
  # Heading
  Body paragraph goes here as plain prose.

Layouts: cover, section, statement, bullets, two-col, split, stat, quote,
compare, code, steps, cards, closing.
"""
import sys, re

KNOWN_KEYS = {
    "title","subtitle","meta","sub","lead","caption","who","number",
    "image","label","no","left","right","a","b","body",
}

def esc(s):
    """Escape Typst markup-significant chars so author text is literal."""
    if s is None:
        return ""
    s = s.replace("\\", "\\\\")
    for ch in "#[]*_`$<>@~":
        s = s.replace(ch, "\\" + ch)
    return s

def content(s):
    """Author text -> a Typst content literal [ ... ], blank lines -> paragraphs."""
    parts = [p.strip() for p in re.split(r"\n\s*\n", s.strip()) if p.strip()]
    body = "\n\n".join(esc(p).replace("\n", " \\\n") for p in parts)
    return "[" + body + "]"

def split_slides(text):
    # strip optional frontmatter
    fm = {}
    m = re.match(r"\s*---\s*\n(.*?)\n---\s*\n", text, re.S)
    if m:
        for ln in m.group(1).splitlines():
            if ":" in ln:
                k, v = ln.split(":", 1)
                fm[k.strip()] = v.strip()
        text = text[m.end():]
    # split on lines beginning with @layout
    chunks = re.split(r"(?m)^@(?=\w)", text)
    slides = []
    for ch in chunks:
        ch = ch.strip("\n")
        if not ch.strip():
            continue
        head, _, rest = ch.partition("\n")
        toks = head.split()
        layout = toks[0]
        opts = {}
        for t in toks[1:]:
            if "=" in t:
                k, v = t.split("=", 1)
                opts[k] = v.strip('"')
        slides.append((layout, opts, rest))
    return fm, slides

def parse_block(rest):
    """Pull headline (#), fields (key:), bullets (-), code fence, and body prose."""
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
            i += 1; continue
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

def cells(items):
    """'- HEAD | BODY' -> list of (head, body) pairs."""
    out = []
    for it in items:
        if "|" in it:
            a, b = it.split("|", 1)
            out.append((a.strip(), b.strip()))
        else:
            out.append((it.strip(), ""))
    return out

def emit(layout, opts, f):
    q = " ".join(f["quote"]).strip()
    body = f["body"]
    if layout == "cover":
        args = [content(field(f, "title", f["title"] or ""))]
        sub = field(f, "subtitle", q)
        if sub: args.append("subtitle: " + content(sub))
        if field(f, "meta"): args.append("meta: " + content(field(f, "meta")))
        return "#cover(" + ", ".join(args) + ")"
    if layout == "section":
        no = opts.get("no") or field(f, "no", "01")
        return f'#section({content(no)}, {content(f["title"] or "")})'
    if layout == "statement":
        args = [content(f["title"] or body)]
        sub = field(f, "sub", q)
        if sub: args.append("sub: " + content(sub))
        return "#statement(" + ", ".join(args) + ")"
    if layout == "closing":
        args = [content(f["title"] or body)]
        sub = field(f, "sub", q)
        if sub: args.append("sub: " + content(sub))
        return "#closing(" + ", ".join(args) + ")"
    if layout == "bullets":
        items = "(" + ", ".join(content(x) for x in f["items"]) + ("," if len(f["items"])==1 else "") + ")"
        args = [content(f["title"] or ""), items]
        lead = field(f, "lead", q)
        if lead: args.append("lead: " + content(lead))
        return "#bullets(" + ", ".join(args) + ")"
    if layout == "steps":
        items = "(" + ", ".join(content(x) for x in f["items"]) + ("," if len(f["items"])==1 else "") + ")"
        return f'#steps({content(f["title"] or "")}, {items})'
    if layout == "two-col":
        left = field(f, "left")
        right = field(f, "right")
        if left is None or right is None:
            paras = re.split(r"\n\s*\n", body.strip())
            left = left or (paras[0] if paras else "")
            right = right or (paras[1] if len(paras) > 1 else "")
        return f'#two-col({content(f["title"] or "")}, {content(left)}, {content(right)})'
    if layout == "split":
        args = [content(f["title"] or ""), content(body)]
        img = opts.get("image") or field(f, "image")
        if img:
            args.append('img: "' + img + '"')
        elif field(f, "label"):
            args.append("label: " + content(field(f, "label")))
        return "#split(" + ", ".join(args) + ")"
    if layout == "stat":
        number = field(f, "number", f["title"] or "")
        caption = field(f, "caption", body or q)
        args = [content(number), content(caption)]
        if field(f, "sub"): args.append("sub: " + content(field(f, "sub")))
        return "#stat(" + ", ".join(args) + ")"
    if layout == "quote":
        args = [content(f["title"] or q or body)]
        if field(f, "who"): args.append("who: " + content(field(f, "who")))
        return "#quote-slide(" + ", ".join(args) + ")"
    if layout == "compare":
        cs = cells(f["items"])
        (ah, ab) = cs[0] if len(cs) > 0 else ("", "")
        (bh, bb) = cs[1] if len(cs) > 1 else ("", "")
        return (f'#compare({content(f["title"] or "")}, '
                f'{content(ah)}, {content(ab)}, {content(bh)}, {content(bb)})')
    if layout == "cards":
        cs = cells(f["items"])
        arr = "(" + ", ".join("(" + content(h) + ", " + content(b) + ")" for h, b in cs) + ("," if len(cs)==1 else "") + ")"
        args = [content(f["title"] or ""), arr]
        if field(f, "lead"): args.append("lead: " + content(field(f, "lead")))
        return "#cards(" + ", ".join(args) + ")"
    if layout == "code":
        lang, code = f["code"] or ("text", body)
        caption = field(f, "caption", q)
        fence = "```" + lang + "\n" + code + "\n```"
        args = [content(f["title"] or ""), "[" + fence + "]"]
        if caption: args.append("caption: " + content(caption))
        return "#code-slide(" + ", ".join(args) + ")"
    raise SystemExit(f"unknown layout: @{layout}")

def main():
    if len(sys.argv) < 2:
        sys.exit("usage: slidegen.py deck.md > _deck.typ")
    text = open(sys.argv[1], encoding="utf-8").read()
    fm, slides = split_slides(text)
    out = ['#import "slides.typ": *', ""]
    for layout, opts, rest in slides:
        f = parse_block(rest)
        out.append(emit(layout, opts, f))
        out.append("")
    sys.stdout.write("\n".join(out))

if __name__ == "__main__":
    main()
