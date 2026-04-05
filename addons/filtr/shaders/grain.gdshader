shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	float n = hash(SCREEN_UV * vec2(1920.0, 1080.0) + vec2(TIME * 60.0, 0.0)) - 0.5;
	COLOR = vec4(clamp(c.rgb + n * amount, 0.0, 1.0), c.a);
}
