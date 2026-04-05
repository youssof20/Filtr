shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float resolution : hint_range(32.0, 1920.0) = 320.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
	float cell = max(tex_size.x / resolution, 1.0);
	vec2 coord = floor(uv * tex_size / cell) * cell / tex_size;
	COLOR = texture(screen_texture, coord);
}
