"""Grid of capture frames with their numbers: capture_grid.py <capture_dir> <out.png> <cols> <frame>..."""
import sys
from PIL import Image, ImageDraw

src, out, cols = sys.argv[1], sys.argv[2], int(sys.argv[3])
frames = [int(f) for f in sys.argv[4:]]
w, h = 640, 360
rows = (len(frames) + cols - 1) // cols
sheet = Image.new("RGB", (cols * w, rows * h), (0, 0, 0))
draw = ImageDraw.Draw(sheet)
for i, f in enumerate(frames):
    im = Image.open("%s/f%08d.png" % (src, f)).convert("RGB")
    x, y = (i % cols) * w, (i // cols) * h
    sheet.paste(im, (x, y))
    draw.rectangle((x, y, x + 60, y + 14), fill=(0, 0, 0))
    draw.text((x + 3, y + 2), str(f), fill=(255, 255, 0))
sheet.save(out)
