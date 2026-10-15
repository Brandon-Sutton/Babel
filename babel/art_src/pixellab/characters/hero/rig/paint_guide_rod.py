"""Paint a key-green guide rod into the hero's near hand (ART_BIBLE §6.3).

    paint_guide_rod.py <east.png> <out.png> <preview_6x.png> [butt_x,butt_y tip_x,tip_y]

Coordinates are in the 96x96 east rotation; the output is padded to 132x132 like
PixelLab's animation canvases. The rod runs from butt to tip through the fist at (49, 54);
the longer side from the fist becomes the blade/head end in the importer.
Defaults: a lowered sword (butt 45,49 -> tip 67,79), used for start_standing.png.
start_standing_pole.png (two-handed pole held upright) used butt 51,68 -> tip 41,6.
"""
import sys
from PIL import Image

src, out, preview = sys.argv[1], sys.argv[2], sys.argv[3]
butt = tuple(int(v) for v in sys.argv[4].split(",")) if len(sys.argv) > 4 else (45, 49)
tip = tuple(int(v) for v in sys.argv[5].split(",")) if len(sys.argv) > 5 else (67, 79)
hero = Image.open(src).convert("RGBA")
PAD = 18
canvas = Image.new("RGBA", (hero.size[0] + 2 * PAD, hero.size[1] + 2 * PAD), (0, 0, 0, 0))
canvas.alpha_composite(hero, (PAD, PAD))
px = canvas.load()
hp = hero.load()

KEY = (0, 255, 0, 255)
EDGE = (0, 120, 0, 255)
GRIP = (49, 54)


def line(a, b):
    (x0, y0), (x1, y1) = a, b
    n = max(abs(x1 - x0), abs(y1 - y0))
    return [(round(x0 + (x1 - x0) * t / n), round(y0 + (y1 - y0) * t / n)) for t in range(n + 1)]


# Thicken across the rod: sideways for steep rods, up/down for flat ones.
flat = abs(tip[0] - butt[0]) > abs(tip[1] - butt[1])
for x, y in line(butt, tip):
    for o, c in ((0, KEY), (1, KEY), (-1, EDGE), (2, EDGE)):
        X, Y = x + (0 if flat else o) + PAD, y + (o if flat else 0) + PAD
        if c == KEY or px[X, Y][3] == 0 or px[X, Y][:3] == EDGE[:3]:
            px[X, Y] = c
# Put the fist (skin pixels around the grip) back on top of the rod.
for y in range(GRIP[1] - 5, GRIP[1] + 4):
    for x in range(GRIP[0] - 4, GRIP[0] + 4):
        r, g, b, a = hp[x, y]
        if a and r > 150 and r > b + 50:
            px[x + PAD, y + PAD] = (r, g, b, a)
canvas.save(out)
big = canvas.resize((canvas.size[0] * 6, canvas.size[1] * 6), Image.NEAREST)
bg = Image.new("RGBA", big.size, (40, 40, 48, 255))
bg.alpha_composite(big)
bg.save(preview)
print("saved", canvas.size)
