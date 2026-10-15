"""Zoomed strip of capture frames (3x): capture_zoom.py <capture_dir> <out.png> x0,y0,x1,y1 <frame>..."""
import sys
from PIL import Image
c, out = sys.argv[1], sys.argv[2]
x0, y0, x1, y1 = [int(v) for v in sys.argv[3].split(",")]
tiles = []
for f in sys.argv[4:]:
    im = Image.open("%s/f%08d.png" % (c, int(f))).convert("RGB").crop((x0, y0, x1, y1))
    tiles.append(im.resize((im.size[0] * 3, im.size[1] * 3), Image.NEAREST))
W = sum(t.size[0] for t in tiles) + 10 * len(tiles); H = max(t.size[1] for t in tiles)
o = Image.new("RGB", (W, H), (60, 0, 60)); x = 0
for t in tiles:
    o.paste(t, (x, 0)); x += t.size[0] + 10
o.save(out)
