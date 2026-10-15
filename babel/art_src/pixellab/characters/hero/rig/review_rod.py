"""Review raw PixelLab guide-prop frames before import (ART_BIBLE §6.3): review_rod.py <frames_dir> <out.png>

For each frame: find the key-green rod, fit its axis, find the grip (where the fist
covers the rod), erase the rod (filling pixels that sat over the body) and draw a
review sheet: original | erased + grip/axis marker, at 3x.
"""
import math
import os
import sys
from PIL import Image, ImageDraw

src, out = sys.argv[1], sys.argv[2]
files = sorted(f for f in os.listdir(src) if f.endswith(".png"))


def is_key(c):
    r, g, b, a = c
    return a > 0 and g > 50 and g > r + 15 and g > b + 15


def is_skin(c):
    r, g, b, a = c
    return a > 0 and r > 150 and r > b + 50 and g > 70


tiles = []
for name in files:
    im = Image.open(os.path.join(src, name)).convert("RGBA")
    w, h = im.size
    px = im.load()
    key = [(x, y) for y in range(h) for x in range(w) if is_key(px[x, y])]
    if len(key) < 4:
        print(name, "no rod")
        continue
    # Principal axis of the rod pixels.
    mx = sum(p[0] for p in key) / len(key)
    my = sum(p[1] for p in key) / len(key)
    sxx = sum((p[0] - mx) ** 2 for p in key)
    syy = sum((p[1] - my) ** 2 for p in key)
    sxy = sum((p[0] - mx) * (p[1] - my) for p in key)
    theta = 0.5 * math.atan2(2 * sxy, sxx - syy)
    ax, ay = math.cos(theta), math.sin(theta)
    ts = [(p[0] - mx) * ax + (p[1] - my) * ay for p in key]
    t0, t1 = min(ts), max(ts)
    # Grip: skin pixels within 3 px of the axis, projected onto it.
    near = []
    for y in range(h):
        for x in range(w):
            if is_skin(px[x, y]):
                d = abs((x - mx) * -ay + (y - my) * ax)
                t = (x - mx) * ax + (y - my) * ay
                if d <= 3.5 and t0 - 4 <= t <= t1 + 4:
                    near.append(t)
    tg = sum(near) / len(near) if near else t0
    grip = (mx + ax * tg, my + ay * tg)
    # Point the axis from the grip toward the longer side (the blade).
    if abs(t1 - tg) < abs(t0 - tg):
        ax, ay = -ax, -ay
    angle = math.degrees(math.atan2(ay, ax))
    # Erase: rod pixels become transparent unless the body surrounds them.
    erased = im.copy()
    ep = erased.load()
    keyset = set(key)
    for x, y in key:
        hits = []
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            for step in range(1, 4):
                X, Y = x + dx * step, y + dy * step
                if 0 <= X < w and 0 <= Y < h and (X, Y) not in keyset:
                    if px[X, Y][3] > 0:
                        hits.append(((dx, dy), px[X, Y]))
                    break
        dirs = {d for d, _ in hits}
        inside = ((1, 0) in dirs and (-1, 0) in dirs) or ((0, 1) in dirs and (0, -1) in dirs)
        ep[x, y] = hits[0][1] if inside else (0, 0, 0, 0)
    print("%s grip (%.1f, %.1f) angle %.0f deg, rod %d px, skin hits %d" % (name, grip[0], grip[1], angle, len(key), len(near)))
    s = 3
    a = im.resize((w * s, h * s), Image.NEAREST)
    b = erased.resize((w * s, h * s), Image.NEAREST)
    tile = Image.new("RGBA", (w * s * 2 + 6, h * s), (40, 40, 48, 255))
    tile.alpha_composite(a, (0, 0))
    tile.alpha_composite(b, (w * s + 6, 0))
    d = ImageDraw.Draw(tile)
    gx, gy = grip[0] * s + w * s + 6, grip[1] * s
    d.line([(gx, gy), (gx + ax * 30 * s / 3 * 3, gy + ay * 30 * s / 3 * 3)], fill=(255, 220, 0, 255), width=1)
    d.ellipse([gx - 4, gy - 4, gx + 4, gy + 4], outline=(255, 60, 60, 255), width=2)
    tiles.append(tile)

cols = 3
tw, th = tiles[0].size
sheet = Image.new("RGBA", (cols * tw, ((len(tiles) + cols - 1) // cols) * th), (20, 20, 24, 255))
for i, t in enumerate(tiles):
    sheet.alpha_composite(t, ((i % cols) * tw, (i // cols) * th))
sheet.save(out)
