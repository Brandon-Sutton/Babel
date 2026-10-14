class_name PixelFont
## Tiny 3x5 bitmap font drawn with rectangles, so HUD text and damage numbers stay
## pixel-crisp at 640x360. Stand-in until the PixelLab font (PIPE-010).

const GLYPH_W: int = 3
const GLYPH_H: int = 5
## Each glyph is 15 bits, rows top to bottom, 3 columns each.
const GLYPHS: Dictionary[String, String] = {
	"0": "111101101101111", "1": "010110010010111", "2": "111001111100111",
	"3": "111001111001111", "4": "101101111001001", "5": "111100111001111",
	"6": "111100111101111", "7": "111001001010010", "8": "111101111101111",
	"9": "111101111001111", "A": "010101111101101", "B": "110101110101110",
	"C": "011100100100011", "D": "110101101101110", "E": "111100110100111",
	"F": "111100110100100", "G": "011100101101011", "H": "101101111101101",
	"I": "111010010010111", "J": "001001001101010", "K": "101101110101101",
	"L": "100100100100111", "M": "101111111101101", "N": "110101101101101",
	"O": "010101101101010", "P": "110101110100100", "Q": "010101101110011",
	"R": "110101110101101", "S": "011100010001110", "T": "111010010010010",
	"U": "101101101101111", "V": "101101101101010", "W": "101101111111101",
	"X": "101101010101101", "Y": "101101010010010", "Z": "111001010100111",
	"/": "001001010100100", ":": "000010000010000", "-": "000000111000000",
	"+": "000010111010000", ".": "000000000000010", "!": "010010010000010",
	" ": "000000000000000",
}


## Width in pixels of [param text] at [param scale].
static func text_width(text: String, scale: int = 1) -> int:
	return maxi(0, text.length() * (GLYPH_W + 1) - 1) * scale


## Draws [param text] (upper-cased) with its top-left at [param position]. A
## non-transparent [param outline] draws a 1-scale-pixel outline around every glyph.
static func draw_text(canvas: CanvasItem, position: Vector2, text: String, color: Color,
		scale: int = 1, outline: Color = Color(0, 0, 0, 0)) -> void:
	var upper: String = text.to_upper()
	if outline.a > 0.0:
		for offset: Vector2 in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			_draw_glyphs(canvas, position + offset * scale, upper, outline, scale)
	_draw_glyphs(canvas, position, upper, color, scale)


static func _draw_glyphs(canvas: CanvasItem, position: Vector2, text: String, color: Color, scale: int) -> void:
	var x: float = position.x
	for character: String in text:
		var bits: String = GLYPHS.get(character, GLYPHS[" "])
		for i: int in bits.length():
			if bits[i] == "1":
				var cell: Vector2 = Vector2(i % GLYPH_W, floori(i / float(GLYPH_W)))
				canvas.draw_rect(Rect2(Vector2(x, position.y) + cell * scale, Vector2(scale, scale)), color)
		x += (GLYPH_W + 1) * scale
