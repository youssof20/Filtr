shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 0.04) = 0.0;
uniform float bands : hint_range(12.0, 200.0) = 64.0;
uniform float speed : hint_range(0.0, 20.0) = 6.0;

void fragment() {
	float b = max(bands, 4.0);
	float row = floor(SCREEN_UV.y * b);
	float n = fract(sin(row * 127.1 + TIME * speed) * 43758.5453123);
	vec2 offs = vec2((n - 0.5) * 2.0 * strength, 0.0);
	vec2 uv = clamp(SCREEN_UV + offs, vec2(0.0), vec2(1.0));
	COLOR = texture(screen_texture, uv);
}
