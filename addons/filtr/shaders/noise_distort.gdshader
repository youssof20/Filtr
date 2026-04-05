shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 0.05) = 0.0;

float n2(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 off = vec2(n2(uv * 400.0), n2(uv * 400.0 + 19.7)) - 0.5;
	COLOR = texture(screen_texture, clamp(uv + off * strength, vec2(0.0), vec2(1.0)));
}
