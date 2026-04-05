shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float saturation : hint_range(-1.0, 1.0) = 0.0;
uniform float contrast : hint_range(-1.0, 1.0) = 0.0;
uniform vec3 rgb_tint = vec3(1.0, 1.0, 1.0);
// Subtle green-phosphor style flicker when both are above zero.
uniform float flicker : hint_range(0.0, 1.0) = 0.0;
uniform float flicker_speed : hint_range(0.0, 40.0) = 0.0;

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	vec3 rgb = c.rgb;
	float luma = dot(rgb, vec3(0.299, 0.587, 0.114));
	rgb = mix(vec3(luma), rgb, clamp(1.0 + saturation, 0.0, 3.0));
	rgb = (rgb - 0.5) * (1.0 + contrast) + 0.5;
	rgb *= rgb_tint;
	if (flicker > 0.001 && flicker_speed > 0.001) {
		float f = 1.0 - flicker * (0.5 + 0.5 * sin(TIME * flicker_speed));
		rgb *= f;
	}
	COLOR = vec4(clamp(rgb, 0.0, 1.0), c.a);
}
