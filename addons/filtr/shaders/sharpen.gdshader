shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount : hint_range(0.0, 2.0) = 0.0;

void fragment() {
	vec2 px = 1.0 / vec2(textureSize(screen_texture, 0));
	vec4 c = texture(screen_texture, SCREEN_UV);
	vec4 blur = (
		texture(screen_texture, SCREEN_UV + vec2(-px.x, 0.0))
		+ texture(screen_texture, SCREEN_UV + vec2(px.x, 0.0))
		+ texture(screen_texture, SCREEN_UV + vec2(0.0, -px.y))
		+ texture(screen_texture, SCREEN_UV + vec2(0.0, px.y))
	) * 0.25;
	vec3 sharp = c.rgb + (c.rgb - blur.rgb) * amount;
	COLOR = vec4(clamp(sharp, 0.0, 1.0), c.a);
}
