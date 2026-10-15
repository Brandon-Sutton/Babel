"""Erase the guide rod in a frame and paint a new one through the same fist:
repaint_rod.py <in.png> <out.png> <preview.png> <angle_deg> <butt_len> <tip_len>
"""
import math
import sys
from PIL import Image

src, out, preview = sys.argv[1], sys.argv[2], sys.argv[3]
angle, butt_len, tip_len = float(sys.argv[4]), float(sys.argv[5]), float(sys.argv[6])
im = Image.open(src).convert("RGBA")
w, h = im.size
px = im.load()
KEY = (0, 255, 0, 255)
EDGE = (0, 120, 0, 255)


def is_key(c):
    r, g, b, a = c
    return a > 0 and g > 50 and g > r + 15 and g > b + 15


def is_skin(c):
    r, g, b, a = c
    return a > 0 and r > 150 and r > b + 50 and g > 70


key = {(x, y) for y in range(h) for x in range(w) if is_key(px[x, y])}
# Grip: mean of skin pixels touching the rod (within 3 px).
skin = [(x, y) for y in range(h) for x in range(w) if is_skin(px[x, y])
        and any((x + dx, y + dy) in key for dx in range(-3, 4) for dy in range(-3, 4))]
gx = sum(p[0] for p in skin) / len(skin)
gy = sum(p[1] for p in skin) / len(skin)
fist = {(x, y): px[x, y] for (x, y) in skin}
# Erase the old rod: fill from body pixels on both sides, else transparent.
orig = im.copy().load()
for (x, y) in key:
    hits = {}
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        for step in range(1, 25):
            X, Y = x + dx * step, y + dy * step
            if not (0 <= X < w and 0 <= Y < h):
                break
            if (X, Y) in key:
                continue
            if orig[X, Y][3] > 0:
                hits[(dx, dy)] = (step, orig[X, Y])
            break
    enclosed = ((1, 0) in hits and (-1, 0) in hits) or ((0, 1) in hits and (0, -1) in hits)
    px[x, y] = min(hits.values())[1] if enclosed else (0, 0, 0, 0)
# Paint the new rod through the fist.
d = (math.cos(math.radians(angle)), math.sin(math.radians(angle)))
a = (gx - d[0] * butt_len, gy - d[1] * butt_len)
b = (gx + d[0] * tip_len, gy + d[1] * tip_len)
n = int(max(abs(b[0] - a[0]), abs(b[1] - a[1])))
for t in range(n + 1):
    x = round(a[0] + (b[0] - a[0]) * t / n)
    y = round(a[1] + (b[1] - a[1]) * t / n)
    for oy, c in ((0, KEY), (1, KEY), (-1, EDGE), (2, EDGE)):
        X, Y = x, y + oy
        if 0 <= X < w and 0 <= Y < h and (c == KEY or px[X, Y][3] == 0):
            px[X, Y] = c
for (x, y), c in fist.items():
    px[x, y] = c
im.save(out)
big = im.resize((w * 5, h * 5), Image.NEAREST)
bg = Image.new("RGBA", big.size, (40, 40, 48, 255))
bg.alpha_composite(big)
bg.save(preview)
print("grip (%.1f, %.1f), rod %s -> %s" % (gx, gy, a, b))
