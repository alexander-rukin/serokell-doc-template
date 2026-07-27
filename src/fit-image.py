#!/usr/bin/env python3
"""Copy an image into the build sandbox, no larger than a slide can show.

Typst embeds a raster exactly as it is handed over - it never downsamples. A
photograph straight off a phone is 4000-6000 px wide and several megabytes; on a
254 mm slide none of that survives the projector, but all of it survives into the
PDF, and a deck with six of them is a file nobody can email.

So the sandbox copy is capped at MAX_PX on its longest side, which is ~260 dpi
across a full-bleed slide and ~310 dpi across an A4 page - past what print needs
and well past what a projector can show. Vector art (SVG, PDF) is left alone:
it has no resolution to cap, and rewriting it would be the one thing that could
lose quality.

Pillow is optional. Without it the file is copied untouched and a line on stderr
says what that costs, because a build that fails on a missing image library is
worse than a build that produces a fat PDF.

Usage: fit-image.py SRC DST
"""
import os
import shutil
import sys

MAX_PX = 2600          # longest side of the copy that lands in the PDF
JPEG_QUALITY = 85      # visually lossless at this scale, roughly a third the size
WARN_BYTES = 1_500_000  # when untouched, say so above this


def note(msg):
    print("image: " + msg, file=sys.stderr)


def mb(n):
    return "%.1f MB" % (n / 1_000_000.0)


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: fit-image.py SRC DST")
    src, dst = sys.argv[1], sys.argv[2]
    ext = os.path.splitext(src)[1].lower()
    size = os.path.getsize(src)

    # vector and animation stay byte-for-byte
    if ext in (".svg", ".pdf", ".gif"):
        shutil.copy2(src, dst)
        return

    try:
        from PIL import Image
    except ImportError:
        shutil.copy2(src, dst)
        if size > WARN_BYTES:
            note("%s is %s and goes into the PDF at full size - install Pillow "
                 "(pip install pillow) and it will be scaled to fit a slide"
                 % (os.path.basename(src), mb(size)))
        return

    try:
        im = Image.open(src)
        im.load()
    except Exception:
        # not something Pillow reads - hand it over and let Typst have its say
        shutil.copy2(src, dst)
        return

    w, h = im.size
    scale = MAX_PX / float(max(w, h))
    if scale < 1:
        im = im.resize((max(1, int(w * scale)), max(1, int(h * scale))),
                       Image.LANCZOS)

    # An alpha channel is a design decision (a logo, a cut-out), so it survives:
    # those stay PNG. Everything else is written as the format it arrived in.
    has_alpha = im.mode in ("RGBA", "LA") or (
        im.mode == "P" and "transparency" in im.info)
    try:
        if ext in (".jpg", ".jpeg") and not has_alpha:
            im.convert("RGB").save(dst, "JPEG", quality=JPEG_QUALITY,
                                   optimize=True, progressive=True)
        elif ext == ".png":
            im.save(dst, "PNG", optimize=True)
        else:
            im.save(dst)
    except Exception:
        shutil.copy2(src, dst)
        return

    # Optimising can cost bytes on a file that was already small and tight.
    out = os.path.getsize(dst)
    if out >= size and scale >= 1:
        shutil.copy2(src, dst)
        return
    if size - out > 200_000:
        note("%s %s -> %s (%dx%d -> %dx%d)"
             % (os.path.basename(src), mb(size), mb(out), w, h,
                im.size[0], im.size[1]))


if __name__ == "__main__":
    main()
