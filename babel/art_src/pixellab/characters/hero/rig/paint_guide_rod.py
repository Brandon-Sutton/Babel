"""Paint a key-green guide rod into the hero's near hand: rig_prop.py <east.png> <out.png> <out_8x.png>"""
import sys
from PIL import Image

src, out, preview = sys.argv[1], sys.argv[2], sys.argv[3]
hero = Image.open(src).convert("RGBA")
PAD = 18
canvas = Image.new("RGBA", (hero.size[0] + 2 * PAD, hero.size[1] + 2 * PAD), (0, 0, 0, 0))
canvas.alpha_composite(hero, (PAD, PAD))
px = canvas.load()
hp = hero.load()

KEY = (0, 255, 0, 255)
EDGE = (0, 120, 0, 255)


def line(a, b):
    (x0, y0), (x1, y1) = a, b
    n = max(abs(x1 - x0), abs(y1 - y0))
    return [(round(x0 + (x1 - x0) * t / n), round(y0 + (y1 - y0) * t / n)) for t in range(n + 1)]


# Rod through the fist: short butt up-back, long shaft down-forward (a lowered sword).
grip = (49, 54)
butt = (45, 49)
tip = (67, 79)
core = line(butt, tip)
for x, y in core:
    for dx, dy, c in ((0, 0, KEY), (1, 0, KEY), (-1, 0, EDGE), (2, 0, EDGE)):
        X, Y = x + dx + PAD, y + dy + PAD
        if c == KEY or px[X, Y][3] == 0 or px[X, Y][:3] in ((0, 120, 0),):
            px[X, Y] = c
# Put the fist (skin pixels around the grip) back on top of the rod.
for y in range(grip[1] - 5, grip[1] + 4):
    for x in range(grip[0] - 4, grip[0] + 4):
        r, g, b, a = hp[x, y]
        if a and r > 150 and r > b + 50:
            px[x + PAD, y + PAD] = (r, g, b, a)
canvas.save(out)
big = canvas.resize((canvas.size[0] * 6, canvas.size[1] * 6), Image.NEAREST)
bg = Image.new("RGBA", big.size, (40, 40, 48, 255))
bg.alpha_composite(big)
bg.save(preview)
print("saved", canvas.size)
