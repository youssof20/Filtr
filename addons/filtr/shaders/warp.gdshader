shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 0.2) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv.x += sin(uv.y * 20.0 + TIME) * strength;
	uv.y += cos(uv.x * 20.0 + TIME) * strength;
	COLOR = texture(screen_texture, clamp(uv, vec2(0.0), vec2(1.0)));
}
