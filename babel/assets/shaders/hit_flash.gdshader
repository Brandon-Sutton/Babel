// Hit flash (VFX-005): blends the sprite toward flash_color by flash (0..1).
// Works for textured sprites and for _draw() primitives (their TEXTURE is white).
shader_type canvas_item;

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	COLOR = vec4(mix(base.rgb, flash_color.rgb, flash), base.a);
}
