shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 0.05) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 o = vec2(strength, 0.0);
	float r = texture(screen_texture, uv + o).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - o).b;
	float a = texture(screen_texture, uv).a;
	COLOR = vec4(r, g, b, a);
}
