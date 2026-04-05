shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float radius : hint_range(0.0, 1.5) = 0.75;
// Optional breathing vignette — when pulse_speed is 0, pulse_amount is ignored.
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed : hint_range(0.0, 24.0) = 0.0;

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	vec2 uv = SCREEN_UV * 2.0 - 1.0;
	float d = length(uv) / max(radius, 0.001);
	float v = mix(1.0, 1.0 - smoothstep(0.35, 1.25, d), strength);
	float pulse = 1.0;
	if (pulse_amount > 0.001 && pulse_speed > 0.001) {
		float b = sin(TIME * pulse_speed) * 0.5 + 0.5;
		pulse = mix(1.0, b, pulse_amount);
	}
	COLOR = vec4(c.rgb * v * pulse, c.a);
}
