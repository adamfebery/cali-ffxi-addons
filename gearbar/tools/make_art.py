"""Draw gearbar's FFXIV-style button art.

    python make_art.py

Reads every jobs/*.lua (and jobs/<Char>/*.lua) for label= / kind= pairs and
draws, into ../art/:
    face_<kind>_<LABEL>.png   one per button (64x64)
    frame_<kind>.png          blank face per kind (fallback for new buttons)
    hover.png pressed.png dim.png   64x64 overlays
    active.png                80x80 gold glow, centred on the slot
    ready.png                 80x80 cyan glow: Quick Draw has a debuff to enhance
    plate_<JOB>.png           the job medallion at the start of the bar

Everything is drawn at 4x and scaled down, for clean anti-aliased edges.

Two looks:
    python make_art.py                 FFXI window style (navy, thin blue edge,
                                       matches gearinfo's meter panel) - default
    python make_art.py --style ffxiv   the original gold-rimmed FFXIV icons
Re-run after adding a button with a new label; until then the addon draws
that button with the plain frame and a text label.
"""

import glob
import os
import re

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
OUT = os.path.join(ROOT, "art")

SIZE = 64            # final slot size
SS = 4               # supersampling
W = SIZE * SS
RADIUS = 11 * SS
GLOW = 8             # active.png extends this far past the slot on each side

FONT = r"C:\Windows\Fonts\palab.ttf"         # Palatino Linotype Bold
FONT_FALLBACK = r"C:\Windows\Fonts\georgiab.ttf"

# (top-left, bottom-right) of each kind's face gradient.
KINDS = {
    "weapon":  ((110, 172, 240), (12, 32, 72)),     # steel blue
    "ws":      ((252, 170, 70), (98, 22, 10)),     # ember orange
    "defense": ((96, 222, 170), (8, 58, 48)),     # jade
    "mode":    ((186, 136, 250), (40, 16, 86)),    # violet
    "utility": ((150, 160, 176), (32, 36, 44)),    # slate
    "roll":    ((236, 88, 100), (78, 8, 22)),      # COR dice red
    "ability": ((156, 172, 240), (22, 28, 84)),    # indigo - job abilities
    "white":   ((226, 236, 255), (72, 92, 142)),   # pale silver-blue - white magic
    "black":   ((170, 120, 210), (26, 10, 52)),    # deep violet - black magic
    "arts":    ((250, 226, 150), (120, 70, 20)),   # gilt - Arts / Addendum / stratagems
    # Elements (COR Quick Draw), in FFXI's own element colours.
    "fire":    ((255, 124, 72), (112, 14, 8)),
    "ice":     ((178, 234, 255), (18, 72, 124)),
    "wind":    ((146, 232, 124), (14, 72, 30)),
    "earth":   ((232, 192, 112), (92, 56, 18)),
    "thunder": ((214, 154, 255), (62, 20, 112)),
    "water":   ((112, 172, 255), (10, 34, 112)),
    "light":   ((255, 248, 214), (168, 136, 64)),
    "dark":    ((136, 92, 158), (16, 6, 26)),
}


def font(px):
    try:
        return ImageFont.truetype(FONT, px)
    except OSError:
        return ImageFont.truetype(FONT_FALLBACK, px)


def rr_mask(size, box, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle(box, radius, fill=255)
    return m


def gradient(size, c1, c2, direction="v"):
    w, h = size
    if direction == "v":
        t = np.linspace(0, 1, h)[:, None].repeat(w, 1)
    else:  # diagonal, top-left -> bottom-right
        y, x = np.mgrid[0:h, 0:w]
        t = (x / w + y / h) / 2
    c1, c2 = np.array(c1, float), np.array(c2, float)
    rgb = c1[None, None, :] * (1 - t[..., None]) + c2[None, None, :] * t[..., None]
    a = np.full((h, w, 1), 255.0)
    return Image.fromarray(np.concatenate([rgb, a], 2).astype(np.uint8))


def radial(size, center, radius, color, alpha):
    w, h = size
    y, x = np.mgrid[0:h, 0:w]
    d = np.sqrt((x - center[0]) ** 2 + (y - center[1]) ** 2) / radius
    a = np.clip(1 - d, 0, 1) ** 1.6 * alpha
    img = np.zeros((h, w, 4))
    img[..., :3] = color
    img[..., 3] = a
    return Image.fromarray(img.astype(np.uint8))


def with_mask(img, mask):
    out = img.copy()
    out.putalpha(ImageChops.multiply(img.getchannel("A"), mask))
    return out


FACE_INSET = 6      # px between slot edge and face; the ffxi style sets 3


def face_box():
    inset = FACE_INSET * SS
    return (inset, inset, W - inset - 1, W - inset - 1), RADIUS - 4 * SS


def slot_base(c1, c2):
    """Bezel, metallic rim and the coloured face - everything but the label."""
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    outer = rr_mask((W, W), (0, 0, W - 1, W - 1), RADIUS)

    # Bezel: dark gunmetal, lighter at the top.
    img.alpha_composite(with_mask(gradient((W, W), (52, 56, 66), (10, 11, 14)), outer))

    # Metallic rim: a bright-to-dark ring just inside the edge.
    ring_inner = rr_mask((W, W), (2 * SS, 2 * SS, W - 2 * SS - 1, W - 2 * SS - 1), RADIUS - 2 * SS)
    ring = ImageChops.subtract(outer, ring_inner)
    img.alpha_composite(with_mask(gradient((W, W), (214, 206, 186), (70, 66, 60)), ring))

    # Face.
    box, r = face_box()
    fmask = rr_mask((W, W), box, r)
    face = gradient((W, W), c1, c2, "d")
    face.alpha_composite(radial((W, W), (W * 0.3, W * 0.28), W * 0.62, (255, 255, 255), 105))
    # Fine noise, so the face reads as a painted icon rather than flat fill.
    noise = (np.random.default_rng(7).normal(0, 7, (W, W, 1))).clip(-20, 20)
    arr = np.asarray(face).astype(float)
    arr[..., :3] = (arr[..., :3] + noise).clip(0, 255)
    face = Image.fromarray(arr.astype(np.uint8))
    img.alpha_composite(with_mask(face, fmask))

    # Inner shadow around the face edge.
    edge = ImageChops.subtract(fmask, fmask.filter(ImageFilter.GaussianBlur(5 * SS)).point(lambda v: 255 if v > 250 else v))
    shadow = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    shadow.putalpha(edge.point(lambda v: int(v * 0.75)))
    img.alpha_composite(with_mask(shadow, fmask))

    # Crisp dark line where face meets bezel.
    line = ImageChops.subtract(fmask, rr_mask((W, W), (box[0] + SS, box[1] + SS, box[2] - SS, box[3] - SS), r - SS))
    dark = Image.new("RGBA", (W, W), (0, 0, 0, 200))
    img.alpha_composite(with_mask(dark, line))
    return img, fmask


def gloss(img, fmask):
    # Soft highlight across the top of the face, like a glazed icon.
    g = Image.new("L", (W, W), 0)
    ImageDraw.Draw(g).ellipse((-W * 0.2, -W * 0.75, W * 1.2, W * 0.46), fill=255)
    g = g.filter(ImageFilter.GaussianBlur(3 * SS))
    fade = gradient((W, W), (255, 255, 255), (255, 255, 255))
    fade.putalpha(ImageChops.multiply(g, Image.fromarray(
        (np.linspace(88, 0, W)[:, None].repeat(W, 1)).astype(np.uint8))))
    img.alpha_composite(with_mask(fade, fmask))


def engrave(img, text, box_center, max_w, size_px, top=(255, 250, 238), bottom=(226, 186, 110)):
    """Gold label with a dark stroke and a soft drop shadow."""
    f = font(size_px)
    while True:
        l, t, r, b = ImageDraw.Draw(img).textbbox((0, 0), text, font=f, stroke_width=3 * SS)
        if r - l <= max_w or size_px <= 8 * SS:
            break
        size_px -= SS
        f = font(size_px)
    tw, th = r - l, b - t
    x = box_center[0] - tw / 2 - l
    y = box_center[1] - th / 2 - t

    shadow = Image.new("L", (W, W), 0)
    ImageDraw.Draw(shadow).text((x + 2 * SS, y + 3 * SS), text, font=f, fill=255, stroke_width=3 * SS, stroke_fill=255)
    sh = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    sh.putalpha(shadow.filter(ImageFilter.GaussianBlur(2.5 * SS)).point(lambda v: int(v * 0.85)))
    img.alpha_composite(sh)

    stroke = Image.new("L", (W, W), 0)
    ImageDraw.Draw(stroke).text((x, y), text, font=f, fill=255, stroke_width=3 * SS, stroke_fill=255)
    img.alpha_composite(with_mask(Image.new("RGBA", (W, W), (22, 14, 6, 255)), stroke))

    fill = Image.new("L", (W, W), 0)
    ImageDraw.Draw(fill).text((x, y), text, font=f, fill=255)
    grad = gradient((W, W), top, bottom)
    # Keep the gradient spanning the glyphs, not the whole slot.
    grad = grad.crop((0, 0, W, W)).resize((W, W))
    img.alpha_composite(with_mask(grad, fill))


def save(img, name, size=SIZE):
    img.resize((size, size), Image.LANCZOS).save(os.path.join(OUT, name), optimize=True)


LUCKY_COLOURS = ((214, 255, 186), (72, 196, 96))      # green
UNLUCKY_COLOURS = ((255, 200, 190), (224, 62, 62))    # red


def badge(img, text, center, colours):
    """A small dark pill with a number on it, for a roll's lucky / unlucky."""
    cx, cy = center
    w, h = (12 if len(text) == 1 else 16) * SS, 12 * SS
    pill = Image.new("L", (W, W), 0)
    ImageDraw.Draw(pill).rounded_rectangle((cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2), h / 2, fill=185)
    img.alpha_composite(with_mask(Image.new("RGBA", (W, W), (12, 6, 8, 255)), pill))
    engrave(img, text, (cx, cy), w, 11 * SS, top=colours[0], bottom=colours[1])


def make_face(kind, label, lucky=None, unlucky=None):
    c1, c2 = KINDS[kind]
    img, fmask = slot_base(c1, c2)
    dice = lucky is not None and unlucky is not None
    if label:
        n = len(label)
        px = {1: 34, 2: 30, 3: 24, 4: 19}.get(n, 16) * SS
        if dice:
            # Leave the bottom of the face for the lucky / unlucky badges.
            engrave(img, label, (W / 2, W / 2 - 5 * SS), W - 16 * SS, px - 2 * SS)
        else:
            engrave(img, label, (W / 2, W / 2 + SS), W - 16 * SS, px)
    if dice:
        badge(img, str(lucky), (17 * SS, W - 16 * SS), LUCKY_COLOURS)
        badge(img, str(unlucky), (W - 17 * SS, W - 16 * SS), UNLUCKY_COLOURS)
    gloss(img, fmask)
    return img


def make_overlays():
    box, r = face_box()
    fmask = rr_mask((W, W), box, r)
    outer = rr_mask((W, W), (0, 0, W - 1, W - 1), RADIUS)

    hover = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    hover.alpha_composite(with_mask(Image.new("RGBA", (W, W), (255, 255, 255, 38)), fmask))
    rim = ImageChops.subtract(outer, rr_mask((W, W), (3 * SS, 3 * SS, W - 3 * SS - 1, W - 3 * SS - 1), RADIUS - 3 * SS))
    hover.alpha_composite(with_mask(Image.new("RGBA", (W, W), (225, 238, 255, 210)), rim))
    save(hover, "hover.png")

    pressed = with_mask(Image.new("RGBA", (W, W), (0, 0, 0, 105)), fmask)
    save(pressed, "pressed.png")

    dim = with_mask(Image.new("RGBA", (W, W), (8, 8, 12, 150)), outer)
    save(dim, "dim.png")

    # Active: warm gold. Ready (Quick Draw has a debuff to enhance): cyan, so
    # "this is on" and "press this now" never look alike.
    make_glow("active.png", halo=(255, 176, 48), crisp=(255, 236, 170), wash=(255, 200, 90))
    make_glow("ready.png", halo=(40, 214, 255), crisp=(196, 246, 255), wash=(90, 220, 255))


def make_glow(name, halo, crisp, wash):
    """A glow bleeding past the slot plus a crisp inner ring, 80x80, centred."""
    G = (SIZE + 2 * GLOW) * SS
    glow = Image.new("RGBA", (G, G), (0, 0, 0, 0))
    o = GLOW * SS
    ring = Image.new("L", (G, G), 0)
    ImageDraw.Draw(ring).rounded_rectangle((o, o, o + W - 1, o + W - 1), RADIUS, outline=255, width=5 * SS)
    halo_mask = ring.filter(ImageFilter.GaussianBlur(4.5 * SS)).point(lambda v: min(255, int(v * 3.2)))
    # Keep the glow off the face itself (it would wash out the label): full
    # strength outside and on the rim, a quarter over the face.
    box, r = face_box()
    face_area = Image.new("L", (G, G), 0)
    ImageDraw.Draw(face_area).rounded_rectangle((o + box[0] + 2 * SS, o + box[1] + 2 * SS,
                                                  o + box[2] - 2 * SS, o + box[3] - 2 * SS), r, fill=190)
    halo_mask = ImageChops.subtract(halo_mask, face_area.filter(ImageFilter.GaussianBlur(2 * SS)))
    glow.alpha_composite(with_mask(Image.new("RGBA", (G, G), halo + (255,)), halo_mask))
    ring2 = Image.new("L", (G, G), 0)
    ImageDraw.Draw(ring2).rounded_rectangle((o + SS, o + SS, o + W - 1 - SS, o + W - 1 - SS), RADIUS - SS, outline=255, width=2 * SS)
    glow.alpha_composite(with_mask(Image.new("RGBA", (G, G), crisp + (255,)), ring2))
    # Faint wash over the face, so a lit button reads as lit at a glance.
    wash_mask = Image.new("L", (G, G), 0)
    ImageDraw.Draw(wash_mask).rounded_rectangle((o + box[0], o + box[1], o + box[2], o + box[3]), r, fill=16)
    glow.alpha_composite(with_mask(Image.new("RGBA", (G, G), wash + (255,)), wash_mask))
    glow.resize((SIZE + 2 * GLOW, SIZE + 2 * GLOW), Image.LANCZOS).save(os.path.join(OUT, name), optimize=True)


def make_plate(job):
    """Job medallion: dark enamel disc in a gold ring, job name engraved."""
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    c = W / 2
    disc = Image.new("L", (W, W), 0)
    ImageDraw.Draw(disc).ellipse((2 * SS, 2 * SS, W - 2 * SS, W - 2 * SS), fill=255)
    img.alpha_composite(with_mask(gradient((W, W), (236, 214, 160), (104, 76, 34)), disc))
    inner = Image.new("L", (W, W), 0)
    ImageDraw.Draw(inner).ellipse((7 * SS, 7 * SS, W - 7 * SS, W - 7 * SS), fill=255)
    enamel = gradient((W, W), (58, 36, 44), (14, 8, 12), "d")
    enamel.alpha_composite(radial((W, W), (c * 0.75, c * 0.6), W * 0.5, (255, 220, 200), 50))
    img.alpha_composite(with_mask(enamel, inner))
    engrave(img, job, (c, c + SS), W - 20 * SS, 20 * SS)
    gloss(img, inner)
    return img


# ---------------------------------------------------------------------------
# FFXI window style: the same look as gearinfo's meter panel. Navy face with
# a thin light-blue edge, the button kind as a coloured band along the top,
# plain white condensed label. Lit = green, "press now" = amber.
# ---------------------------------------------------------------------------

FFXI_FONT = r"C:\Windows\Fonts\bahnschrift.ttf"
FFXI_TOP, FFXI_BOT = (40, 60, 114), (13, 21, 50)
FFXI_EDGE = (143, 166, 216)
FFXI_GOLD = (217, 180, 90)
FFXI_RADIUS = 5 * SS


def ffxi_font(px):
    try:
        f = ImageFont.truetype(FFXI_FONT, px)
        f.set_variation_by_name("SemiBold Condensed")
        return f
    except (OSError, ValueError):
        return ImageFont.truetype(r"C:\Windows\Fonts\ARIALNB.TTF", px)


def mix(a, b, t):
    return tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3))


def ffxi_base(accent):
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    outer = rr_mask((W, W), (0, 0, W - 1, W - 1), FFXI_RADIUS)
    img.alpha_composite(with_mask(Image.new("RGBA", (W, W), FFXI_EDGE + (255,)), outer))
    box, r = face_box()
    fmask = rr_mask((W, W), box, r)
    # Navy face with a light tint of the kind's colour, so kinds still read apart.
    face = gradient((W, W), mix(FFXI_TOP, accent, 0.18), mix(FFXI_BOT, accent, 0.10))
    img.alpha_composite(with_mask(face, fmask))
    # Kind band along the top of the face.
    band = Image.new("L", (W, W), 0)
    ImageDraw.Draw(band).rectangle((0, 0, W, box[1] + 6 * SS), fill=255)
    img.alpha_composite(with_mask(Image.new("RGBA", (W, W), accent + (255,)), ImageChops.multiply(band, fmask)))
    # Faint top-lit line under the band, like the game's window frames.
    hl = Image.new("L", (W, W), 0)
    y = box[1] + 6 * SS
    ImageDraw.Draw(hl).rectangle((0, y, W, y + SS), fill=70)
    img.alpha_composite(with_mask(Image.new("RGBA", (W, W), (255, 255, 255, 255)), ImageChops.multiply(hl, fmask)))
    return img, fmask


def ffxi_label(img, text, center, max_w, size_px, colour=(241, 243, 250)):
    f = ffxi_font(size_px)
    while True:
        l, t, r, b = ImageDraw.Draw(img).textbbox((0, 0), text, font=f, stroke_width=SS)
        if r - l <= max_w or size_px <= 8 * SS:
            break
        size_px -= SS
        f = ffxi_font(size_px)
    x = center[0] - (r - l) / 2 - l
    y = center[1] - (b - t) / 2 - t
    stroke = Image.new("L", (W, W), 0)
    ImageDraw.Draw(stroke).text((x, y), text, font=f, fill=255, stroke_width=int(1.5 * SS), stroke_fill=255)
    img.alpha_composite(with_mask(Image.new("RGBA", (W, W), (0, 0, 0, 170)), stroke))
    fill = Image.new("L", (W, W), 0)
    ImageDraw.Draw(fill).text((x, y), text, font=f, fill=255)
    img.alpha_composite(with_mask(Image.new("RGBA", (W, W), colour + (255,)), fill))


def ffxi_badge(img, text, center, colour):
    cx, cy = center
    w, h = (12 if len(text) == 1 else 16) * SS, 11 * SS
    pill = Image.new("L", (W, W), 0)
    ImageDraw.Draw(pill).rounded_rectangle((cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2), 2 * SS, fill=200)
    img.alpha_composite(with_mask(Image.new("RGBA", (W, W), (0, 0, 0, 255)), pill))
    ffxi_label(img, text, (cx, cy), w, 10 * SS, colour)


def make_face_ffxi(kind, label, lucky=None, unlucky=None):
    accent = mix(KINDS[kind][0], KINDS[kind][1], 0.35)
    img, fmask = ffxi_base(accent)
    dice = lucky is not None and unlucky is not None
    if label:
        n = len(label)
        px = {1: 34, 2: 30, 3: 26, 4: 22}.get(n, 18) * SS
        cy = W / 2 + 2 * SS if not dice else W / 2 - 3 * SS
        ffxi_label(img, label, (W / 2, cy), W - 10 * SS, px - (3 * SS if dice else 0))
    if dice:
        ffxi_badge(img, str(lucky), (17 * SS, W - 13 * SS), (110, 210, 140))
        ffxi_badge(img, str(unlucky), (W - 17 * SS, W - 13 * SS), (255, 107, 107))
    return img


def make_overlays_ffxi():
    global RADIUS
    RADIUS = FFXI_RADIUS
    box, r = face_box()
    fmask = rr_mask((W, W), box, r)
    outer = rr_mask((W, W), (0, 0, W - 1, W - 1), FFXI_RADIUS)
    rim = ImageChops.subtract(outer, rr_mask((W, W), (2 * SS, 2 * SS, W - 2 * SS - 1, W - 2 * SS - 1), FFXI_RADIUS - 2 * SS))

    hover = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    hover.alpha_composite(with_mask(Image.new("RGBA", (W, W), (255, 255, 255, 30)), fmask))
    hover.alpha_composite(with_mask(Image.new("RGBA", (W, W), FFXI_GOLD + (255,)), rim))
    save(hover, "hover.png")
    save(with_mask(Image.new("RGBA", (W, W), (0, 0, 0, 110)), fmask), "pressed.png")
    save(with_mask(Image.new("RGBA", (W, W), (8, 12, 28, 160)), outer), "dim.png")
    # Lit = green (same as "capped" in gearinfo). Ready / press now = amber.
    make_glow("active.png", halo=(70, 200, 110), crisp=(150, 240, 175), wash=(110, 210, 140))
    make_glow("ready.png", halo=(240, 170, 50), crisp=(255, 222, 150), wash=(240, 180, 76))


def make_plate_ffxi(job):
    img, fmask = ffxi_base(FFXI_GOLD)
    ffxi_label(img, job, (W / 2, W / 2 + 3 * SS), W - 10 * SS, 24 * SS, FFXI_GOLD)
    return img


def buttons_in_job_files():
    """(kind, label, lucky, unlucky) per button, and job names, from
    jobs/*.lua and jobs/*/*.lua. lucky / unlucky are None unless the line
    has lucky= / unlucky= (Phantom Rolls)."""
    faces, jobs = {}, set()
    files = glob.glob(os.path.join(ROOT, "jobs", "*.lua")) + glob.glob(os.path.join(ROOT, "jobs", "*", "*.lua"))
    for path in files:
        jobs.add(os.path.splitext(os.path.basename(path))[0].upper())
        for line in open(path, encoding="utf-8"):
            if line.lstrip().startswith("--"):
                continue
            label = re.search(r"label\s*=\s*'([^']+)'", line)
            kind = re.search(r"kind\s*=\s*'(\w+)'", line)
            if label and kind and kind.group(1) in KINDS:
                lucky = re.search(r"\blucky\s*=\s*(\d+)", line)
                unlucky = re.search(r"\bunlucky\s*=\s*(\d+)", line)
                faces[(kind.group(1), label.group(1))] = (
                    lucky and int(lucky.group(1)), unlucky and int(unlucky.group(1)))
    return sorted((k, l, *faces[(k, l)]) for k, l in faces), sorted(jobs)


def safe(label):
    return re.sub(r"[^A-Za-z0-9]", "_", label)


def main():
    global FACE_INSET
    import sys
    ffxi = "--style" not in sys.argv or sys.argv[sys.argv.index("--style") + 1] != "ffxiv"
    if ffxi:
        FACE_INSET = 3
    face_fn = make_face_ffxi if ffxi else make_face
    os.makedirs(OUT, exist_ok=True)
    pairs, jobs = buttons_in_job_files()
    # gearbar adds this itself whenever a job file has pop-out menus.
    if not any(k == "utility" and l == "BACK" for k, l, _, _ in pairs):
        pairs.append(("utility", "BACK", None, None))
    for kind in KINDS:
        save(face_fn(kind, None), f"frame_{kind}.png")
    for kind, label, lucky, unlucky in pairs:
        save(face_fn(kind, label, lucky, unlucky), f"face_{kind}_{safe(label)}.png")
    (make_overlays_ffxi if ffxi else make_overlays)()
    for job in jobs:
        save((make_plate_ffxi if ffxi else make_plate)(job), f"plate_{job}.png")
    print(f"[{'ffxi' if ffxi else 'ffxiv'} style] {len(pairs)} button faces, {len(KINDS)} frames, {len(jobs)} job plates -> art/")


if __name__ == "__main__":
    main()
