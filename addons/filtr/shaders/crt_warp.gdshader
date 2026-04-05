shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// How strongly the picture bends outward like a curved CRT face (barrel distortion).
uniform float bend_amount : hint_range(0.0, 1.0) = 0.0;
// Horizontal scan-line dimming — soft bright/dark bands using a sine pattern.
uniform float line_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 c = uv * 2.0 - 1.0;
	float r2 = dot(c, c);
	float k = bend_amount * 0.42;
	vec2 warped = c * (1.0 + k * r2);
	uv = warped * 0.5 + 0.5;
	vec4 col = texture(screen_texture, clamp(uv, vec2(0.001), vec2(0.999)));
	if (line_strength > 0.001) {
		vec2 ts = vec2(textureSize(screen_texture, 0));
		float rows = max(ts.y * 0.48, 1.0);
		float line = sin(SCREEN_UV.y * rows * 6.2831853);
		float dim = mix(1.0, 0.72 + 0.28 * line, line_strength);
		col.rgb *= dim;
	}
	COLOR = col;
}
