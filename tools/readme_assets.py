"""Regenerate README images: PreviewRes/banner.png and PreviewRes/gallery/*.png.

Usage: python tools/readme_assets.py
Requires Pillow and the Windows fonts Bahnschrift.
"""
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PREVIEW = os.path.join(ROOT, "PreviewRes")
LOGO = os.path.join(ROOT, "_BsKeyTools", "logo.bmp")
BAHN = r"C:\Windows\Fonts\bahnschrift.ttf"

SLATE = "#5f8499"
TEXT = "#e6eff3"
MINT = "#98e3d5"
SHADOW = "#1d3546"
WHITE = "#ffffff"

GALLERY = ["01", "09", "06", "08", "07", "02"]
NO_CROP = {"09"}


def font(size, var):
    f = ImageFont.truetype(BAHN, size)
    f.set_variation_by_name(var)
    return f


def rounded(im, radius):
    w, h = im.size
    s = 4
    mask = Image.new("L", (w * s, h * s), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w * s - 1, h * s - 1], radius=radius * s, fill=255)
    out = im.convert("RGBA")
    out.putalpha(mask.resize((w, h), Image.LANCZOS))
    return out


def signature(color, height):
    alpha = ImageOps.invert(Image.open(LOGO).convert("L"))
    alpha = alpha.point(lambda v: 0 if v < 40 else min(255, int((v - 40) * 1.25)))
    alpha = alpha.crop(alpha.getbbox())
    alpha = alpha.resize((int(alpha.width * height / alpha.height), height), Image.LANCZOS)
    img = Image.new("RGBA", alpha.size, color)
    img.putalpha(alpha)
    return img


def make_banner():
    w, h, margin, top_line = 2560, 640, 64, 120
    im = Image.new("RGB", (w, h), SLATE)
    d = ImageDraw.Draw(im)

    small = font(30, b"SemiBold")
    d.text((margin, 84), "ALL FOR ANIMATOR", font=small, fill=TEXT, anchor="ls")
    d.text((w / 2, 84), "3DS MAX ANIMATION TOOLKIT", font=small, fill=TEXT, anchor="ms")
    d.text((w - margin, 84), "SINCE 2019 / 100+ TOOLS", font=small, fill=TEXT, anchor="rs")

    d.line([(margin, top_line), (w - margin, top_line)], fill=TEXT, width=3)
    span = w - 2 * margin
    for i in range(121):
        x = margin + span * i / 120
        major = i % 10 == 0
        d.line([(x, top_line), (x, top_line + (22 if major else 10))], fill=TEXT, width=3 if major else 2)
    for i in (0, 18, 41, 66, 90, 120):
        x, s = margin + span * i / 120, 13
        d.polygon([(x, top_line - s), (x + s, top_line), (x, top_line + s), (x - s, top_line)], fill=TEXT)

    title = "BsKeyTools"
    size = 600
    while True:
        big = font(size, b"Bold Condensed")
        l, t, r, b = d.textbbox((0, 0), title, font=big, anchor="ls")
        if b - t <= h - top_line - 60 - 48:
            break
        size -= 4
    d.text((margin - l, h - 48 - b), title, font=big, fill=WHITE, anchor="ls")

    sig = signature(MINT, 210).rotate(8, resample=Image.BICUBIC, expand=True)
    shadow = Image.new("RGBA", sig.size, SHADOW)
    shadow.putalpha(sig.getchannel("A"))
    sx, sy = w - margin - sig.width + 10, 250
    im.paste(shadow, (sx + 12, sy + 12), shadow)
    im.paste(sig, (sx, sy), sig)

    rounded(im, 28).save(os.path.join(PREVIEW, "banner.png"), optimize=True)


def crop_viewport(im):
    # Viewport background is bluish (b - r >= 30); UI panels are neutral grey.
    mask = Image.new("L", im.size, 0)
    src, dst = im.load(), mask.load()
    for y in range(im.height):
        for x in range(im.width):
            r, _, b = src[x, y]
            if b - r < 30:
                dst[x, y] = 255
    return im.crop(mask.getbbox())


def make_tile(name, tile=720, pad=36):
    im = Image.open(os.path.join(PREVIEW, f"{name}.png")).convert("RGB")
    if name not in NO_CROP:
        im = crop_viewport(im)
    s = min((tile - 2 * pad) / im.width, (tile - 2 * pad) / im.height, 1.6)
    im = im.resize((round(im.width * s), round(im.height * s)), Image.LANCZOS)

    canvas = Image.new("RGB", (tile, tile), SLATE)
    x, y = (tile - im.width) // 2, (tile - im.height) // 2
    shadow = Image.new("L", (tile, tile), 0)
    ImageDraw.Draw(shadow).rectangle([x + 6, y + 10, x + im.width + 6, y + im.height + 10], fill=90)
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    canvas.paste(Image.new("RGB", (tile, tile), (20, 34, 44)), (0, 0), shadow)
    canvas.paste(im, (x, y))

    rounded(canvas, 20).save(os.path.join(PREVIEW, "gallery", f"{name}.png"), optimize=True)


def main():
    os.makedirs(os.path.join(PREVIEW, "gallery"), exist_ok=True)
    make_banner()
    for name in GALLERY:
        make_tile(name)
    print("README assets written to", PREVIEW)


if __name__ == "__main__":
    main()
