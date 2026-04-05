shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 0.2) = 0.0;
uniform float frequency : hint_range(4.0, 36.0) = 14.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	float f = frequency;
	uv.x += sin(uv.y * f + TIME) * strength;
	uv.y += cos(uv.x * f + TIME) * strength;
	COLOR = texture(screen_texture, clamp(uv, vec2(0.0), vec2(1.0)));
}
