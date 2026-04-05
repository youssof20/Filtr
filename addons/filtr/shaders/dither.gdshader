shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 1.0) = 0.5;
uniform int pattern : hint_range(0, 3) = 0;

float bayer4(vec2 frag_px) {
	vec2 p = mod(floor(frag_px), 4.0);
	float x = p.x;
	float y = p.y;
	// 4x4 Bayer matrix, flattened
	if (y < 1.0) {
		if (x < 1.0) return 0.0 / 16.0;
		if (x < 2.0) return 8.0 / 16.0;
		if (x < 3.0) return 2.0 / 16.0;
		return 10.0 / 16.0;
	} else if (y < 2.0) {
		if (x < 1.0) return 12.0 / 16.0;
		if (x < 2.0) return 4.0 / 16.0;
		if (x < 3.0) return 14.0 / 16.0;
		return 6.0 / 16.0;
	} else if (y < 3.0) {
		if (x < 1.0) return 3.0 / 16.0;
		if (x < 2.0) return 11.0 / 16.0;
		if (x < 3.0) return 1.0 / 16.0;
		return 9.0 / 16.0;
	}
	if (x < 1.0) return 15.0 / 16.0;
	if (x < 2.0) return 7.0 / 16.0;
	if (x < 3.0) return 13.0 / 16.0;
	return 5.0 / 16.0;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 c = texture(screen_texture, uv);
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
	vec2 px = uv * tex_size;
	float th = bayer4(px + float(pattern) * 0.25);
	float levels = mix(32.0, 4.0, strength);
	vec3 q = floor(c.rgb * levels + th * strength) / max(levels, 1.0);
	COLOR = vec4(mix(c.rgb, q, strength), c.a);
}
