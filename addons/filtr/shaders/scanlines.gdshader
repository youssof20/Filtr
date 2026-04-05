shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 1.0) = 0.5;
uniform float line_spacing : hint_range(1.0, 8.0) = 2.0;

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
	float y = SCREEN_UV.y * tex_size.y;
	float m = abs(sin(y * 3.14159 / line_spacing));
	float dim = mix(1.0, 0.85, m * strength);
	COLOR = vec4(c.rgb * dim, c.a);
}
