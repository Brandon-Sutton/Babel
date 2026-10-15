shader_type canvas_item;
// EQV-006 (v1): recolors Elam's body for the equipped armor and mantle (GDD §6.7).
// Pixels are classed by colour: "plates" are the light, unsaturated steel below the
// neck (hair is grey too, so it is excluded by height), "lining" is the saturated
// crimson of the cape. Each class is remapped by lightness onto a dark/mid/light ramp.
// Ramps are given in sRGB; with HDR 2D on, texture reads are linear, so the classes and
// ramps are computed in sRGB and converted back.

uniform bool dye_plates = false;
uniform vec3 plates_dark = vec3(0.2);
uniform vec3 plates_mid = vec3(0.5);
uniform vec3 plates_light = vec3(0.9);
uniform bool dye_lining = false;
uniform vec3 lining_dark = vec3(0.2, 0.0, 0.05);
uniform vec3 lining_mid = vec3(0.55, 0.08, 0.15);
uniform vec3 lining_light = vec3(0.93, 0.42, 0.42);
// Local y of the neck (feet = 0, up is negative); plates are only below it.
uniform float neck_y = -70.0;

varying vec2 local_pos;
// Modulate on its own: in fragment(), COLOR already includes the texture.
varying vec4 tint;

void vertex() {
	local_pos = VERTEX;
	tint = COLOR;
}

vec3 to_srgb(vec3 c) {
	return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), c));
}

vec3 to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

vec3 ramp(vec3 dark, vec3 mid, vec3 light, float t) {
	return t < 0.5 ? mix(dark, mid, t * 2.0) : mix(mid, light, t * 2.0 - 1.0);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 s = to_srgb(c.rgb);
	float hi = max(s.r, max(s.g, s.b));
	float lo = min(s.r, min(s.g, s.b));
	float lightness = (hi + lo) * 0.5;
	vec3 out_rgb = c.rgb;
	if (dye_plates && local_pos.y > neck_y && hi - lo < 0.13 && lightness > 0.36) {
		out_rgb = to_linear(ramp(plates_dark, plates_mid, plates_light, clamp((lightness - 0.36) / 0.6, 0.0, 1.0)));
	} else if (dye_lining && s.r > 0.2 && s.r > s.g * 2.2 && s.r > s.b * 1.3) {
		out_rgb = to_linear(ramp(lining_dark, lining_mid, lining_light, clamp(lightness / 0.6, 0.0, 1.0)));
	}
	COLOR = vec4(out_rgb, c.a) * tint;
}
